//
//  ErrorReporter.swift
//
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation
import OSLog

let report_log = OSLog(subsystem: "com.wildthink.carbon", category: "report")

infix operator ??: NilCoalescingPrecedence

//@MainActor
public struct ErrorReporter {
    var fn: (Error) -> Void
    
    public init(fn: @escaping (Error) -> Void) {
        self.fn = fn
    }
    
    public func callAsFunction(_ error: Error) {
        fn(error)
    }
    
    // MARK: Conenience Reporters

    public static func oslog(_ msg: @escaping @autoclosure () -> String) -> ErrorReporter {
        ErrorReporter { error in
            os_log(.debug, log: report_log, "%s: %s", msg(), error.localizedDescription)
        }
    }

    public static let print = ErrorReporter {
        Swift.print($0)
    }

    public static let log = ErrorReporter {
        Logger.carbon.info("Received error:\($0)")
    }

    public static var `default` = ErrorReporter {
        Logger.carbon.info("Received error:\($0)")
    }
}

//@MainActor
public func ?? <T>(lhs: @autoclosure () throws -> T, rhs: ErrorReporter) -> T? {
    
    do {
        return try lhs()
    } catch {
        rhs(error)
    }
    return nil
}

infix operator ?!: NilCoalescingPrecedence

//@MainActor
public func ?! <T>(lhs: @autoclosure () throws -> T, rhs: ErrorReporter) throws -> T {
    do {
        return try lhs()
    } catch {
        rhs(error)
        throw error
    }
}

public func ?! <T>(lhs: T?, rhs: @autoclosure () -> Error) throws -> T {
    
    if let value = lhs {
        return value
    }
    
    throw rhs()
}

infix operator !!: NilCoalescingPrecedence

public func !! <T>(lhs: T?, rhs: @autoclosure () -> String) -> T {
    
    if let value = lhs {
        return value
    }
    
    fatalError("Error unwrapping value of type \(T.self): \(rhs())")
}

public func unimplemented(_ fn: String = #function,
                          file: StaticString = #file, line: UInt = #line
) -> Never  {
    fatalError("\(fn) at \(file):\(line) is not implemented.")
}

public func undefined(_ fn: String = #function,
                          file: StaticString = #file, line: UInt = #line
) -> Never  {
    fatalError("\(fn) at \(file):\(line) is not implemented.")
}

#if BAD
// public typealias None = Never
//  Carbon
//  Created by Jason Jobe on 8/2/24.
//
import OSLog
/// `Unimplemented` logs an umimplemented function or closure
/// befor a `fatalError`.
public func Unimplemented(_ fn: String = #function,
                          file: StaticString = #file, line: UInt = #line
) -> Never  {
    Logger.carbon.fault("\(fn) at \(file):\(line) is not implemented.")
    fatalError("\(fn) at \(file):\(line) is not implemented.")
}

/// Use `report(..)` instead of the lazy  developer`let v = try? call(...)`
/// All LogLevels are reported as specified using OSLog.
/// ### __WARNING!!__
/// The `OSLogEntryLog.Level.fault` ALSO calls `fatalError()`
/// after logging the error.
public func report<Value>(
    _ loglevel: OSLogEntryLog.Level = .notice,
    file: StaticString = #fileID, line: UInt = #line,
    call: () throws -> Value
) -> Value?  {
    let log = Logger.carbon
    do {
        return try call()
    } catch {
        switch loglevel {
            case .fault:
                log.fault("\(error) at \(file):\(line) is not implemented.")
                fatalError()
            case .debug:
                log.debug("\(error) at \(file):\(line) is not implemented.")
            case .undefined:
                log.debug("\(error) at \(file):\(line) is not implemented.")
            case .info:
                log.info("\(error) at \(file):\(line) is not implemented.")
            case .notice:
                log.notice("\(error) at \(file):\(line) is not implemented.")
            case .error:
                log.error("\(error) at \(file):\(line) is not implemented.")
            @unknown default:
                log.debug("\(error) at \(file):\(line) is not implemented.")
        }
    }
    return nil
}
#endif

//  Created by Dave DeLong on 8/18/23.
//  ExtendedSwift

public struct AnyError: Error, CustomStringConvertible {
    
    public let function: StaticString
    public let fileID: StaticString
    public let line: UInt
    public let description: String
    public let underlyingError: Error?
    
    public init(_ description: String = "AnyError", function: StaticString = #function, fileID: StaticString = #fileID, line: UInt = #line) {
        self.function = function
        self.fileID = fileID
        self.line = line
        self.description = description
        self.underlyingError = nil
    }
    
    public init(_ other: Error, function: StaticString = #function, fileID: StaticString = #fileID, line: UInt = #line) {
        if let any = other as? AnyError {
            self = any
        } else {
            self.function = function
            self.fileID = fileID
            self.line = line
            self.description = other.localizedDescription
            self.underlyingError = other
        }
    }
    
}

public struct UnimplementedError: Error, CustomStringConvertible {
    
    public let function: StaticString
    public let fileID: StaticString
    public let line: UInt
    
    public init(function: StaticString = #function, file: StaticString = #fileID, line: UInt = #line) {
        self.function = function
        self.fileID = file
        self.line = line
    }
    
    public var description: String {
        "The function \(function) in \(fileID):\(line) is unimplemented. This is a developer error."
    }
    
}

public struct Unreachable: Error, CustomStringConvertible {
    
    public let function: StaticString
    public let fileID: StaticString
    public let line: UInt
    
    public init(function: StaticString = #function, file: StaticString = #fileID, line: UInt = #line) {
        self.function = function
        self.fileID = file
        self.line = line
    }
    
    public var description: String {
        "The function \(function) in \(fileID):\(line) should be unreachable. This is a developer error."
    }
    
}
