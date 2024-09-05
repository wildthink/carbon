//
//  Intent.swift
//  AppPackage
//
//  Created by Jason Jobe on 8/4/24.
//

import Foundation

public struct Intent : Sendable {
    public typealias IntentFn = @Sendable () -> Void
    public private(set) var title: String
    public private(set) var symbol: String = "gearshape"
    public private(set) var fn: IntentFn
    
    public init(title: String, symbol: String, fn: @escaping IntentFn) {
        self.title = title
        self.symbol = symbol
        self.fn = fn
    }

    public func callAsFunction() -> Void { fn() }
}

public extension Intent {
    
    // CRUD
    static func create(_ fn: IntentFn? = nil) -> Intent {
        let fn = fn ?? { print("create") }
        return Intent(title: "Create", symbol: "plus", fn: fn)
    }
    
    static func update(_ fn: IntentFn? = nil) -> Intent {
        let fn = fn ?? { print("update") }
        return Intent(title: "Update", symbol: "plus", fn: fn)
    }

    static func delete(_ fn: IntentFn? = nil) -> Intent {
        let fn = fn ?? { print("delete") }
        return Intent(title: "Delete", symbol: "trash", fn: fn)
    }

    // MISC
    static func cancel(_ fn: IntentFn? = nil) -> Intent {
        let fn = fn ?? { print("cancel") }
        return Intent(title: "Cancel", symbol: "xmark", fn: fn)
    }
    
    static func debug(_ fn: IntentFn? = nil) -> Intent {
        let fn = fn ?? { print("Debugged Intent") }
        return Intent(title: "Debug", symbol: "ladybug", fn: fn)
    }

}
