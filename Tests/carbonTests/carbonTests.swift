import XCTest
@testable import Carbon

final class carbonTests: XCTestCase {
    
    func testDefaultValues() throws {
        struct Test {
            var i: Int
        }
        
        AssertNoError { try DefaultValue(for: Int.self) }
        AssertNoError { try DefaultValue(for: Double.self) }
        AssertNoError { try DefaultValue(for: Int64.self) }
        AssertNoError { try DefaultValue(for: String.self) }
        AssertNoError { try DefaultValue(for: String?.self) }
        AssertNoError { try DefaultValue(for: Test?.self) }
    }
    
    func testSafeDecoder() throws {
        struct Test: Decodable {
            var str: String
            var opt: String?
            var int: Int
            var real: Double
            var tags: [Int]
            var set: Set<String>
            var date: Date
        }
        
        let plist: [String : Any?] = [
            "str": "text",
            "opt": nil,
            "int": 23,
            "real": 69.7,
            "date": Date.now,
            "tags": [1, 2, 3],
            "set": ["a", "b"],
        ]
        
        let t1: Date = try SafeDecoder.decode(from: Date().timeIntervalSince1970)
        print(t1)
        
        let x1 = try [Int](from: SafeDecoder(from: [1, 2, 3]))
        let x2 = try Set<Int>(from: SafeDecoder(from: [5, 1, 3]))
        print (type(of: x2))
        print(x1, x2)
        
        let t2 = try Test(from: SafeDecoder(from: plist))
        let t3 = try Test(from: SafeDecoder(from: ["date": 0]))
        print(t1, t2, t3)
    }
}

extension XCTestCase {
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
