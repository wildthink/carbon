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
public struct TypeSchema: Identifiable {
    public let id: ObjectIdentifier
    public var name: String { String(describing: valueType) }
    public let valueType: Any.Type
    public let fields: [(key: String, path: AnyKeyPath)]
    
    public init<A>(_ valueType: A.Type) {
        self.id = ObjectIdentifier(A.self)
        self.valueType = valueType
        self.fields = Carbon14.fields(of: A.self)
    }
    
    public func keypath(for key: String) -> AnyKeyPath? {
        fields.first(where: { $0.key == key })?.path
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

@_spi(Schematics)
public extension TypeSchema {
    static var _cache: [ObjectIdentifier:TypeSchema] = [:]

    static func clearCache() {
        _cache = [:]
    }
    
    static func cache<A>(for: A.Type) -> TypeSchema? {
        _cache[ObjectIdentifier(A.self)]
    }
    static func cache(insert: TypeSchema) {
        _cache[insert.id] = insert
    }
}
