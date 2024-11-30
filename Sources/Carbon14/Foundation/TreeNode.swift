//
//  TreeNode.swift
//  Carbon14
//
//  Created by Jason Jobe on 11/11/24.
//


import Foundation

// Data structure to represent a node in the tree
public class TreeNode: @unchecked Sendable {
    public var key: String
    public var value: Any?
    public var children: [TreeNode]

    public init(key: String, value: Any? = nil, children: [TreeNode] = []) {
        self.key = key
        self.value = value
        self.children = children
    }
    
    public init?(keys: [String], value: Any? = nil) {
        guard let first = keys.first else { return nil }
        self.key = first
        if keys.count == 1 {
            self.value = value
            children = []
        } else {
            let rest = Array(keys.dropFirst())
            if let node = TreeNode(keys: rest, value: value) {
                children = [node]
            } else {
                return nil
            }
        }
    }

    public func merge(keys: [String], value: Any? = nil) {
        
        guard let first = keys.first else {
            self.value = value
            return
        }
        let rest = Array(keys.dropFirst())
        
        if first == self.key {
            self.value = value
        }
        else if let child = children.first(where: { $0.key == first }) {
            child.merge(keys: rest, value: value)
        }
        else {
            let node = TreeNode(key: first)
            node.merge(keys: rest, value: value)
            children.append(node)
        }
    }

    // Add a child to the current node
    public func addChild(_ child: TreeNode) {
        children.append(child)
    }

}

extension TreeNode {
    public func prettyPrint(_ prefix: String = "", _ isLast: Bool = true) {
        print("\(prefix)\(isLast ? "└── " : "├── ")\(key)")
        
        let newPrefix = prefix + (isLast ? "    " : "│   ")
        for (index, child) in children.enumerated() {
            let childIsLast = index == children.count - 1
            child.prettyPrint(newPrefix, childIsLast)
        }
    }
}

extension TreeNode: CustomStringConvertible {
    public var description: String {
        let vs = value == nil ? "" : ":\(String(describing: value!))"
        if children.isEmpty {
            return "(\(key)\(vs))\n"
        } else {
            return "(\(key)\(vs) \(children.map(\.description).joined(separator: " ")))\n"
        }
    }
}
