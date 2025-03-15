//
//  Tree.swift
//  Carbon14
//
//  Created by Jason Jobe on 1/24/25.
//


//
//  Tree.swift
//
//  Created by Jason Jobe on 01/23/2025
//

import Foundation

@dynamicMemberLookup
public final class Tree<Value> {
    public var value: Value
    /// Depth in the Tree, Zero being the root
    public var level: Int
    ///  Index in parent's children array
    public var index: Int
    public private(set) var children: [Tree]
    public var memo: String?
    
    public var count: Int {
        1 + children.reduce(0) { $0 + $1.count }
    }

    public init(_ value: Value, memo: String? = nil) {
        self.value = value
        self.level = 0
        self.index = 0
        self.memo = memo
        children = []
    }

    public init(_ value: Value, memo: String? = nil, children: [Tree]) {
        self.value = value
        self.level = 0
        self.index = 0
        self.memo = memo
        self.children = children
        children.enumerated().forEach { index, child in
            child.level = self.level + 1
            child.index = index
        }
    }

    public subscript<M>(dynamicMember keyPath: KeyPath<Value, M>) -> M {
        value[keyPath: keyPath]
    }
    
//    public init(_ value: Value, @TreeBuilder builder: () -> [Tree]) {
//        self.value = value
//        self.children = builder()
//    }

    public func add(child: Tree) {
        child.level = self.level + 1
        child.index = children.count
        children.append(child)
    }
}

extension Tree: Equatable where Value: Equatable {
    public static func ==(lhs: Tree, rhs: Tree) -> Bool {
        lhs.value == rhs.value && lhs.children == rhs.children
    }
}

extension Tree: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(children)
    }
}

extension Tree: CustomStringConvertible {
    public var description: String {
        let indent = String(repeating: " ", count: level)
        var result = "\(indent)\(level):\(index) \(memo ?? "")"
        
        if !children.isEmpty {
            print(to: &result)
        }
        for child in children {
            print(child.description, to: &result)
//            result += "\n" + child.description
        }
        
        return result
    }
}

extension Tree: Codable where Value: Codable { }

public extension Tree where Value: Equatable {
    func find(_ value: Value) -> Tree? {
        if self.value == value {
            return self
        }

        for child in children {
            if let match = child.find(value) {
                return match
            }
        }

        return nil
    }
}

@resultBuilder
struct TreeBuilder {
    static func buildBlock<Value>(_ children: Tree<Value>...) -> [Tree<Value>] {
        children
    }
}
