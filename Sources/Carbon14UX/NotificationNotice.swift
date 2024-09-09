//
//  Notice.swift
//  SurfboardPackage
//
//  Created by Jason Jobe on 9/3/24.
//
import Foundation
import Combine
import SwiftUI

@propertyWrapper
public struct Notice<Value>: DynamicProperty {
    @Environment(\.notificationCenter) var notificationCenter
    @StateObject private var core: Core
    
    public var wrappedValue: Value {
        get { core.value }
        nonmutating set { core.value = newValue }
    }
    
    public init(wrappedValue: Value, _ notificationName: Notification.Name) {
        _core = StateObject(wrappedValue: Core(notificationName: notificationName, initialValue: wrappedValue))
    }

    public init(wrappedValue: Value = Value.nilValue, _ notificationName: Notification.Name) where Value: AnyOptional {
        _core = StateObject(wrappedValue: Core(notificationName: notificationName, initialValue: wrappedValue))
    }

    public init(wrappedValue: Value = Value.zero, _ notificationName: Notification.Name) where Value: AdditiveArithmetic {
        _core = StateObject(wrappedValue: Core(notificationName: notificationName, initialValue: wrappedValue))
    }

    public mutating func update() {
        core.monitor(notificationCenter)
    }
    
    public var projectedValue: Self {
        self
    }
}

public protocol AnyOptional {
  static var nilValue: Self { get }
  var wrapped: Any? { get }
}

extension Optional: AnyOptional {
    public static var nilValue: Optional<Wrapped> { nil }

    public var wrapped: Any? {
    switch self {
    case let .some(value):
      return value
    case .none:
      return nil
    }
  }
}

extension Notice where Value == Notification? {
    public init(_ notificationName: Notification.Name) {
        _core = StateObject(wrappedValue: Core(notificationName: notificationName, initialValue: nil))
    }
}

extension Notice {
    class Core: ObservableObject {
        @Published var value: Value
        private var cancellable: AnyCancellable?
        var notificationName: Notification.Name
        
        init(notificationName: Notification.Name, initialValue: Value) {
            self.notificationName = notificationName
            self.value = initialValue
        }
        
        func monitor(_ center: NotificationCenter) {
            cancellable = center.publisher(for: notificationName)
                .compactMap { ($0 as? Value) ?? $0.object as? Value }
//                .receive(on: RunLoop.main)
                .assign(to: \.value, on: self)
        }
    }
}

enum NotificationCenterKey: EnvironmentKey {
    static var defaultValue: NotificationCenter = .default
}

extension EnvironmentValues {
    public var notificationCenter: NotificationCenter {
        get { self[NotificationCenterKey.self] }
        set { self[NotificationCenterKey.self] = newValue }
    }
}

// MARK: Other

struct Patch<Root> {
    var fn: (inout Root) -> Void
    init<V>(_ keyp: WritableKeyPath<Root,V>, _ value: V) {
        fn = { $0[keyPath: keyp] = value }
    }
}

@dynamicMemberLookup
class Modifier<Root> {
    var root: Root

    init(_ root: Root) {
        self.root = root
    }
    
    subscript <V>(dynamicMember keyPath: ReferenceWritableKeyPath<Root, V>) -> (V) -> Modifier<Root> {
        { self.root[keyPath: keyPath] = $0; return self }
//        get { root[keyPath: keyPath] }
//        set { root[keyPath: keyPath] = newValue }
    }
}

class Demo {
    var key: String
    var count: Int
    
    init(key: String = "", count: Int = 0) {
        self.key = key
        self.count = count
    }
}

private func example() {
    let demo = Demo(key: "Hello", count: 10)
    let modifier = Modifier(demo)
        .count(8)
        .key("okey")
//    let d = Demo().count(1)
    
    
    print(modifier.root.key)
}
