//
//  TypeSchema.swift
//  Carbon14
//
//  Created by Jason Jobe on 9/6/24.
//
import Foundation

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
