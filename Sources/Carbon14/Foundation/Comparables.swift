//
//  Comparables.swift
//  Carbon
//
//  Created by Jason Jobe on 8/6/24.
//
import Foundation

/// A nil value is < than a non-nil value
extension String? {
    public static func < (lhs: String?, rhs: String?) -> Bool {
        switch (lhs, rhs) {
            case (nil, nil):
                return false
            case (nil, _):
                return true
            case (_, nil):
                return false
            case (let left, let right):
                return left < right
        }
    }
}

extension Array where Element: Comparable {
    public static func < (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
        for (left, right) in zip(lhs, rhs) {
            if left < right {
                return true
            } else if left > right {
                return false
            }
        }
        return lhs.count < rhs.count
    }
}

//  Created by Dave DeLong on 4/1/23.

extension Comparable {
    
    public func compare(_ other: Self) -> ComparisonResult {
        if self < other { return .orderedAscending }
        if self == other { return .orderedSame }
        return .orderedDescending
    }
    
}

extension Collection {
    
    public var isNotEmpty: Bool { isEmpty == false }

    public func sorted<V: Comparable>(by value: (Element) -> V) -> Array<Element> {
        return sorted(by: {
            value($0) < value($1)
        })
    }
    
    public func max<C: Comparable>(of property: (Element) -> C) -> C? {
        return self.lazy.map(property).max()
    }
    
    public func min<C: Comparable>(of property: (Element) -> C) -> C? {
        return self.lazy.map(property).min()
    }
    
    public func max<C: Comparable>(by property: (Element) -> C) -> Element? {
        return self.max(by: { (l, r) -> Bool in
            let lValue = property(l)
            let rValue = property(r)
            return lValue < rValue
        })
    }
    
    public func min<C: Comparable>(by property: (Element) -> C) -> Element? {
        return self.min(by: { (l, r) -> Bool in
            let lValue = property(l)
            let rValue = property(r)
            return lValue < rValue
        })
    }
    
    public func range<C: Comparable>(of value: (Element) -> C) -> ClosedRange<C>? {
        guard isNotEmpty else { return nil }
        
        let firstValue = value(self[startIndex])
        var range = firstValue ... firstValue
        
        for index in self.indices.dropFirst() {
            let itemValue = value(self[index])
            if itemValue < range.lowerBound { range = itemValue ... range.upperBound }
            if itemValue > range.upperBound { range = range.lowerBound ... itemValue }
        }
        return range
    }
    
}

extension Collection where Element: Comparable {
    
    public var max: Element? {
        return self.max(by: { $0 })
    }
    
    public var min: Element? {
        return self.min(by: { $0 })
    }
    
    public var range: ClosedRange<Element>? {
        return self.range(of: { $0 })
    }
    
}
