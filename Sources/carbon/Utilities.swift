//
//  Utilities.swift
//  Carbon
//
//  Created by Jason Jobe on 8/2/24.
//

import Foundation
import OSLog

let log = Logger(subsystem: "carbon", category: "log")

/// `Unimplemented` logs an umimplemented function or closure
/// befor a `fatalError`.
public func Unimplemented(_ fn: String = #function,
                          file: StaticString = #file, line: UInt = #line
) -> Never  {
    log.fault("\(fn) at \(file):\(line) is not implemented.")
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
