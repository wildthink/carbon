//
//  AnySendable.swift
//  Carbon
//
//  Created by Jason Jobe on 8/13/24.
//

import Foundation

public struct AnySendable: Sendable {
    private let box: any _AnySendableBox

    public init<T: Sendable>(_ value: T) {
        self.box = SendableBox(value)
    }
    
    public func value<T: Sendable>() -> T? {
        return (box as? SendableBox<T>)?.value
    }
}

// The protocol that both boxes conform to, ensuring Sendable conformance
private protocol _AnySendableBox: Sendable {}

private struct SendableBox<T: Sendable>: _AnySendableBox {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}
