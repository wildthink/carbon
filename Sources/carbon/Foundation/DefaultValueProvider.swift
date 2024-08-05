//
//  DefaultValueProvider.swift
//  Carbon
//
//  Created by Jason Jobe on 8/1/24.
//

import Foundation

/// A `DefaultValueProvider` is any type that can provide an honest value.
/// We don't want to require a default `init()` for the type but this is
/// typically what you would want to return.
public protocol DefaultValueProvider {
    static var defaultValue: Self { get }
}

/// The `DefaultValue` function is rhe preferred way to generate an "empty"
/// or zero value Any.Type since if provides the "obvious" default values of
/// an empty string, zero numeric value, false, or nil when it can.
public func DefaultValue(for at: Any.Type) throws -> Any {
    
    return switch at {
        case let t as DefaultValueProvider.Type:
            t.defaultValue
        case is any StringProtocol.Type:
            ""
        case is Bool.Type:
            false
        case let t as (any AdditiveArithmetic.Type):
            t.zero
        case let t as (any ExpressibleByNilLiteral.Type):
            t.init(nilLiteral: ())
        default:
            throw DefaultValueError.noDefaultValueFor(at)
    }
}

public func DefaultValue<A>(for at: A.Type = A.self) throws -> A {
    guard let v = try DefaultValue(for: A.self) as? A
    else {
        throw DefaultValueError.noDefaultValueFor(A.self)
    }
    return v
}

extension Dictionary: DefaultValueProvider {
    public static var defaultValue: Self { [:] }
}

extension Array: DefaultValueProvider {
    public static var defaultValue: Self { [] }
}

extension Set: DefaultValueProvider {
    public static var defaultValue: Self { [] }
}

public enum DefaultValueError: Error {
    case noDefaultValueFor(Any.Type)
}
