//
//  TestExtensions.swift
//  Carbon
//
//  Created by Jason Jobe on 8/1/24.
//

import XCTest

public extension XCTestCase {
    
    func AssertThrows(
        message: String = "",
        file: StaticString = #filePath, line: UInt = #line,
        _ block: () throws -> ()
    ) {
        do {
            try block()
            let msg = (message == "") ? "Tested block expected to throw." : message
            XCTFail(msg, file: file, line: line)
        } catch {
            print("GOOD throw", error)
        }
        return
    }

    @discardableResult
    func AssertNoError<Value>(
        message: String = "",
        file: StaticString = #filePath, line: UInt = #line,
        _ block: () throws -> Value
    ) -> Value? {
        do {
            return try block()
        } catch {
            let msg = (message == "") ? "Tested block threw unexpected error." : message
            XCTFail(msg, file: file, line: line)
        }
        return nil
    }
}
