@testable import Carbon14
import XCTest

class AnyCodableTests: XCTestCase {
    
    func testJSONDecoding() throws {
        let json = """
        {
            "boolean": true,
            "integer": 1,
            "double": 3.14159265358979323846,
            "string": "string",
            "array": [1, 2, 3],
            "nested": {
                "a": "alpha",
                "b": "bravo",
                "c": "charlie"
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let dictionary = try decoder.decode([String: AnyCodable].self, from: json)
        let plist = try JSONSerialization.jsonObject(with: json) as? NSDictionary
        if let undict = dictionary.unwrappedValue as? NSDictionary {
            XCTAssert(undict.isEqual(to: plist))
        } else {
            XCTFail()
        }
    }
    
    func testJSONEncoding() throws {
        let dictionary: [String: AnyCodable] = [
            "boolean": true,
            "integer": 1,
            "double": 3.14159265358979323846,
            "string": "string",
            "array": [1, 2, 3],
            "nested": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie",
            ],
        ]
        
        let encoder = JSONEncoder()
        
        let json = try encoder.encode(dictionary)
        let encodedJSONObject = try JSONSerialization.jsonObject(with: json, options: []) as! NSDictionary
        if let undict = dictionary.unwrappedValue as? NSDictionary {
            XCTAssert(undict.isEqual(to: encodedJSONObject))
        } else {
            XCTFail()
        }
    }
    
    static var allTests = [
        ("testJSONDecoding", testJSONDecoding),
        ("testJSONEncoding", testJSONEncoding),
    ]
}
