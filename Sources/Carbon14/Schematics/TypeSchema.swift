//
//  TypeSchema.swift
//  Carbon14
//
//  Created by Jason Jobe on 9/6/24.
//
import Foundation

/**
 A ``TypeSchema`` provides an easy way to encapsulate some basic meta data about you
 class or type. The simplist way is to add an extension to one your protocols (see example).
 The object is lazily created and cached and provides the ``valueType`` and an array
 mapping the string-name of a property to its KeyPath, giving you a type-safe to read
 and write a property value by "name".
 
 ``` swift
 extension MyProtocol {
     static var schema: TypeSchema { TypeSchema(Self.self) }
 }
```
 
 The schema also performs as a Lens with get and set by key-name methods.
 */
@dynamicMemberLookup
public final class TypeSchema: Identifiable {
    public let id: ObjectIdentifier
    public var name: String { String(describing: valueType) }
    public let valueType: Any.Type
    public let fields: [(key: String, path: AnyKeyPath)]
    public var userInfo: [AnyHashable:Any] = [:]
    
    @_spi(Schematics)
//    public init<A>(valueType: A.Type) {
    public init(valueType: Any.Type) {
        self.id = ObjectIdentifier(valueType)
        self.valueType = valueType
        self.fields = Carbon14.fields(of: valueType)
    }
    
    public func keypath(for key: String) -> AnyKeyPath? {
        fields.first(where: { $0.key == key })?.path
    }
    
    public subscript<V>(dynamicMember key: String) -> V? {
        get { userInfo[key] as? V }
        set { userInfo[key] = newValue }
    }
}

extension TypeSchema {
    
    public static func recall(_ valueType: Any.Type) -> TypeSchema {
        if let it = TypeSchemaCache.shared[valueType] { return it }
        let it = TypeSchema(valueType: valueType)
        TypeSchemaCache.shared[it.id] = it
        return it
    }
}

public extension TypeSchema {
    func get<N>(_ key: String, from nob: N) -> Any? {
        guard let kp = keypath(for: key) else { return nil }
        return nob[keyPath: kp]
    }
    
    func set<N, V>(_ key: String, of nob: inout N, to newValue: V) {
        guard let kp = keypath(for: key) as? WritableKeyPath<N,V>
        else { return }
        nob[keyPath: kp] = newValue
    }

}

extension TypeSchema: CustomStringConvertible  {
    public var description: String {
        var s = "\(name): {\n"
        for f in fields {
            print("  \(f.0): \(f.1)", to: &s)
        }
        print("}", to: &s)
        return s
    }
}

private class TypeSchemaCache {

    private let lock: os_unfair_lock_t
    private var storage = [ObjectIdentifier:TypeSchema]()

    static let shared = TypeSchemaCache()
    private init() {
        self.lock = .allocate(capacity: 1)
        self.lock.initialize(to: os_unfair_lock_s())
    }

    subscript(oid: ObjectIdentifier) -> TypeSchema? {
        get {
            storage[oid]
        }
        set {
            os_unfair_lock_lock(lock); defer { os_unfair_lock_unlock(lock) }
            storage[oid] = newValue
        }
    }

    subscript(type: Any.Type) -> TypeSchema? {
        get {
            storage[ObjectIdentifier(type)]
        }
        set {
            os_unfair_lock_lock(lock); defer { os_unfair_lock_unlock(lock) }
            storage[ObjectIdentifier(type)] = newValue
        }
    }
}
