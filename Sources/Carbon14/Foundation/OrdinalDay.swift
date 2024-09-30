//
//  OrdinalDay.swift
//  pal
//
//  Created by Jason Jobe on 9/28/24.
//

import Foundation

// https://freetools.textmagic.com/rrule-generator
/**
 An ``OrdinalDay`` represents an "expression" that specifies "some day"
 in a semantically meaninful way. This can be a specific Date in time or a generalizing
 expression meaning "every <nth> day" in some time period, where "nth" is a cardinal
 index of days in that perios.
 
 For example:
 - "every day"
 - "every Monday"
 - "every 1st of the month"
 - "every 1st of January"
 - "every first of the year"
 
 */
public typealias Day = OrdinalDay
public struct OrdinalDay: Codable, Hashable, Equatable, Sendable {
    
    public enum Period: Int, Codable, Comparable, Hashable, Equatable {
        public static func < (lhs: OrdinalDay.Period, rhs: OrdinalDay.Period) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
        
        case julian, year
        case month // any month
        case january, february, march, april,
             may, june, july, august, september,
             october, november, december
        case week  // Sunday, Monday, ..., Weekday, Weekend
        case day  // every day
        
        var isCalendarMonth: Bool { self >= .month && self <= .december }
        // Returns 1-31 if the Period is jan..dec, Zero otherwise
        var ordinalMonthValue: Int {
            isCalendarMonth ? (rawValue - Period.month.rawValue) : 0
        }
    }
    
    var rawValue: UInt32
    
    public init(date: Date) {
        rawValue = UInt32(date.julianDate)
    }
    
    public init(day: Int, of period: Period) {
        let val = switch period {
            case .day: day
            case .week: (day + 1000)
            case .year: (day + 2000)
            case .month,
                 .january, .february, .march, .april,
                 .may, .june, .july, .august,
                 .september, .october, .november, .december:
                (3000 + (100 * period.ordinalMonthValue) + day)
            case .julian: day
        }
        rawValue = UInt32(val)
    }
    
    public var stride: Double {
        switch period {
            case .julian: 0.0
            case .day:    1.0
            case .week:   7.0
            case .year:   365.24
            case .month:  30.4
            // Jan ... Dec
            // stride is year e.g. Jan 1 till next Jan 1
            default:      365.24
        }
    }
    public var julianDay: Date? {
        guard period == .julian else { return nil }
        return Date(julianDate: Double(rawValue))
    }
    
    public var period: Period {
        switch rawValue {
            case 0...999:
                return .day
            case 1000...1999:
                return .week
            case 2000...2999:
                return .year
            case 3000...4999:
                let md = Int(rawValue - 3000)
                let mon = Int(md / 100)
                return Period(rawValue: mon + Period.month.rawValue) ?? .month
            default:
                return .julian
        }
    }
    
    public var ordinalValue: Int {
        switch period {
            case .day:
                return Int(rawValue)
            case .week:
                return Int(rawValue - 1000)
            case .year:
                return Int(rawValue - 2000)
            case .month,
                 .january, .february, .march, .april,
                 .may, .june, .july, .august,
                 .september, .october, .november, .december:
                let md = Int(rawValue - 3000)
                let mon = Int(md / 100)
                let day = md - (mon * 100)
                return day
            case .julian:
                return Int(rawValue)
        }
    }
    
    public func firstMatch(from date: Date) -> Date {
        if let julianDay {
            return julianDay
        }
        if matches(date) { return date }
        // Find next matching date based on period
        // Implementation depends on your requirements for periods
        return date
    }
    
    public func matches(_ date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        switch period {
            case .julian:
                return julianDay?.sameDay(as: date) ?? false
            case .year:
                return calendar.ordinality(of: .day, in: .year, for: date) == ordinalValue
            case .month:
                return calendar.ordinality(of: .day, in: .month, for: date) == ordinalValue
            case .week:
                return calendar.ordinality(of: .weekday, in: .weekOfYear, for: date) == ordinalValue
            case .day:
                return calendar.component(.day, from: date) == ordinalValue
            case .january, .february, .march, .april, .may, .june, .july, .august, .september, .october, .november, .december:
                return calendar.component(.month, from: date) == period.ordinalMonthValue &&
                calendar.component(.day, from: date) == ordinalValue
        }
    }
}

extension Date {
    // Get the next specific day of the week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
    func next(dayOfWeek: Int) -> Date? {
        let calendar = Calendar.current
        guard let nextDate = calendar.nextDate(
            after: self,
            matching: DateComponents(weekday: dayOfWeek),
            matchingPolicy: .nextTime)
        else {
            return nil
        }
        return nextDate
    }
    
    // Get the next specific day of the month (next month if day is in the past, or specified month)
    func next(day: Int, of month: Int? = nil) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        
        if let month = month {
            components.month = month
        } else {
            components.month = (components.month ?? 0) + 1
        }
        components.day = day
        return calendar.nextDate(after: self, matching: components, matchingPolicy: .nextTime)
    }
}

public extension Date {
    
    func sameDay(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: other)
    }
}

/*
func ~=(lhs: Int, rhs: ClosedRange<Int>) -> Bool {
    lhs >= rhs.lowerBound && lhs <= rhs.upperBound
}

func ~=(lhs: Int, rhs: Range<Int>) -> Bool {
    lhs >= rhs.lowerBound && lhs < rhs.upperBound
}

func foo() -> Bool {
    8 ~= 0..<365 &&
    8 ~= 0...365
}
*/

extension OrdinalDay: CustomStringConvertible {
    public var description: String {
        if let date = julianDay {
            return date.description
        }
        let p = String(describing: period)
        return "\(ordinalValue)_nth of \(p)"
    }
}

#if DEBUG
let strategy = Date.ParseStrategy(
    format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
    locale: Locale.current,
    timeZone: TimeZone(abbreviation: "UTC")!)

func testOrdinalDay() {
    // YYYY-MM-DD
    let date = try! Date("2024-09-28", strategy: strategy)
    print(date)
    checkDay(27, of: .month, date: date)
    checkDay(28, of: .month, date: date)
    checkDay(10, of: .year, date: date)
    checkDay(6, of: .week, date: date)
    
    // checkDay(9, of: .september, date: date)
    checkDay(27, of: .september, date: date)
    checkDay(28, of: .september, date: date)
    
    let day = OrdinalDay(date: date)
    print(day.period, day)
    
    var flag = OrdinalDay(date: .now).matches(date)
    print(#line, flag)
    
    flag = OrdinalDay(date: date).matches(date)
    print(#line, flag)
}

func checkDay(_ day: Int, of p: OrdinalDay.Period, date: Date) {
    let oday = OrdinalDay(day: day, of: p)
    let good = oday.matches(date)
    print(good, oday.rawValue, oday, "=>", date.formatted(date: .abbreviated, time: .omitted))
}

#endif
