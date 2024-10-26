//
//  Template.swift
//  Surfboard
//
//  Created by Jason Jobe on 2/23/24.
//

import Foundation

public struct Template<Root>: ExpressibleByStringInterpolation {
    
    enum Fragment {
        case literal(String)
        case key(PartialKeyPath<Root>)
        case style(PartialKeyPath<Root>, any FormatStyle)
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        var parts: [Fragment]
        
        public init(literalCapacity: Int, interpolationCount: Int) {
            parts = []
        }
        
        mutating public func appendLiteral(_ literal: String) {
            parts.append(.literal(literal))
        }
        
        mutating public func appendInterpolation<T>(_ keyPath: KeyPath<Root, T>) {
            parts.append(.key(keyPath))
        }
        
        mutating public
        func appendInterpolation<V, S: FormatStyle>(
            _ keyPath: KeyPath<Root, V>,
            format: S
        ) where V == S.FormatInput {
            parts.append(.key(keyPath))
        }
    }
    
    var parts: [Fragment] = []

    public init(stringLiteral value: String) {
        parts = [.literal(value)]
    }
    
    public init(stringInterpolation: StringInterpolation) {
        self.parts = stringInterpolation.parts
    }
}

public extension Template {
    func string(with root: Root) -> String {
        var str = ""
        for p in parts {
            switch p {
                case .key(let keyp):
                    let value = root[keyPath: keyp]
                    str.append(String(describing: value))
                case .literal(let literal):
                    str.append(literal)
                case .style(let keyp, let fmt):
                    let value = root[keyPath: keyp]
                    if let sval = String(value, formatStyle: fmt) {
                        str.append(sval)
                    }
            }
        }
        return str
    }
}

public extension String {
    init?<V>(_ value: V, formatStyle: some FormatStyle) {
        guard let fmt = formatStyle.format as? ((V) -> String)
        else { return nil }
        self = fmt(value)
    }
}
