//
//  ArrayBuilder.swift
//
//
//  Created by Jason Jobe on 6/13/24.
//

import Foundation

// Inspired by https://gist.github.com/rjchatfield/72629b22fa915f72bfddd96a96c541eb
/// The `ArrayBuilder` is just too handy.
/// ``` swift
/// @ArrayBuilder<String>
/// func foo(flag: Bool) -> [String] {
///     if flag {
///        "TRUE"
///     } else {
///        "FALSE
///     }
/// }
/// ```
///
/// You can also add extenstions for your types to customize the final result
///
/// ``` swift
/// extension ArrayBuilder where Element == String {
///    public static func buildFinalResult(_ component: [Element]) -> String {
///       component.joined(separator: "")
///    }
/// }
///
/// @ArrayBuilder<String> func foo(flag: Bool) -> String {
///    ...
/// }
/// ```
///
@resultBuilder
public struct ArrayBuilder<Element> {
    
    // MARK: Block from Expression
    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }
    
    public static func buildExpression(_ expression: [Element]) -> [Element] {
        return expression
    }
    
    // Optionals
    public static func buildExpression(_ expression: Element?) -> [Element] {
        return expression.map { [$0] } ?? []
    }
    
    public static func buildExpression(_ expression: [Element]?) -> [Element] {
        return expression ?? []
    }

    // MARK: Block Building
    public static func buildPartialBlock(first: Element) -> [Element] { [first] }
    public static func buildPartialBlock(first: [Element]) -> [Element] { first }
    
    public static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] { accumulated + [next] }
    @_disfavoredOverload
    public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] { accumulated + next }
    
    // Empty block
    public static func buildBlock() -> [Element] { [] }
    
    // Empty partial block. Useful for switch cases to represent no elements.
    public static func buildPartialBlock(first: Void) -> [Element] { [] }
    
    // Impossible partial block. Useful for fatalError().
    public static func buildPartialBlock(first: Never) -> [Element] {}
    
    // Block for an 'if' condition.
    public static func buildIf(_ element: [Element]?) -> [Element] { element ?? [] }
    
    // Block for an 'if' condition which also have an 'else' branch.
    public static func buildEither(first: [Element]) -> [Element] { first }
    
    // Block for the 'else' branch of an 'if' condition.
    public static func buildEither(second: [Element]) -> [Element] { second }
    
    // Block for an array of elements. Useful for 'for' loops.
    public static func buildArray(_ components: [[Element]]) -> [Element] { components.flatMap { $0 } }
}

public extension Array {
    init(@ArrayBuilder<Element> _ builder: () -> [Element]) {
        self.init(builder())
    }
}
