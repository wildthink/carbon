//
//  ComponentsContainer.swift
//  Carbon
//
//  Created by Jason Jobe on 6/8/24.
//

#if READY
/// The `ValueContainer` follows the SwiftUI EnvironmentValues pattern
/// in providing an extensible, type-safe Dictionary. Additional extensions can
/// be added to support more "embedded" values
@dynamicMemberLookup
public struct ComponentsContainer<Subject: DefaultValueProvider> {
    private var values: [AnyHashable:Any] = [:]
    
    public init() {}
    
    public subscript<Value>(dynamicMember key: WritableKeyPath<Subject, Value>) -> Value {
        mutating get { component(Subject.self)[keyPath: key] }
        mutating set { component(Subject.self)[keyPath: key] = newValue }
    }

    public mutating
    func component<A>(_ ctype: A.Type = A.self
    ) -> A where A: DefaultValueProvider {
        let key = ObjectIdentifier(ctype)
        if let c = values[key] as? A { return c }
        let c = A.defaultValue
        values[key] = c
        return c
    }

    @_disfavoredOverload
    public func component<A>(_ ctype: A.Type = A.self) -> A? {
        values[ObjectIdentifier(ctype)] as? A
    }    
}
#endif

