//
//  Test.swift
//  Carbon14
//
//  Created by Jason Jobe on 8/16/24.
//

import XCTest
@testable import Carbon14
//import OSLog


final class FileTests: XCTestCase {
    
    func testPath() {
        let ext = "ext"
        
        let p1 = /"home"/"town"/ext
        print(p1)
        print(~/"dev")
    }
    
}


//import Testing

//struct Test {
//
//    @Test func <#test function name#>() async throws {
//        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//    }
//
//}
