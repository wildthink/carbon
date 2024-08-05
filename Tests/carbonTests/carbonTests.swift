import XCTest
@testable import Carbon

final class carbonTests: XCTestCase {
    
    func testDefaultValues() throws {
        struct Test {
            var i: Int
        }
        
        let xi: Int64 = try DefaultValue()
        XCTAssert(Int64.zero == xi)
        
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
        
        let now = Date()
        
        let plist: [String : Any?] = [
            "str": "text",
            "opt": nil,
            "int": 23,
            "real": 69.7,
            "date": now,
            "tags": [1, 2, 3],
            "set": ["a", "b"],
        ]

        let x1 = try [Int](from: SafeDecoder(from: [1, 2, 3]))
        let x2 = try Set<Int>(from: SafeDecoder(from: [5, 1, 3]))
        print(x1, x2)
        
        AssertThrows {
            _ = try Set<String>(from: SafeDecoder(from: [1, 3]))
        }

        let t1: Date = try SafeDecoder.decode(from: Date().timeIntervalSince1970)
        let t2 = try Test(from: SafeDecoder(from: plist))
        let t3 = try Test(from: SafeDecoder(from: ["date": 0]))
        let t4 = try Test(from: SafeDecoder(from: ["date": now]))
        print(t1, t2, t3, t4)
    }
    
    func testMID64() {
        let generator = MID64Generator()
        let uniqueID = generator.generateID()
        print("Unique ID: \(uniqueID)")
        
        let extractedDate = uniqueID.extractDate()
        print("Extracted Date: \(extractedDate)")
        
        let m = MID64(tag: 15)
        print("MI64", m.timestamp, m.counter, m.tag)
    }

    func testErrorHandling() {
        let errorReporter: ErrorReporter = .default
        func badFunction() throws -> Int {
            throw NSError(domain: #function, code: 0)
        }
        
        let result: Int? = 1 ?? errorReporter
        print("Result: \(String(describing: result))")
        XCTAssert(result == 1)
        
        let result2: Int? = try badFunction() ?? .print
        print("Result2: \(String(describing: result2))")
        XCTAssertNil(result2)
        
        AssertThrows {
            let result3: Int? = try badFunction() ?! errorReporter
            print("Result3: \(String(describing: result3))")
        }
    }
}
