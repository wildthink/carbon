//
//  Comparables.swift
//  Carbon
//
//  Created by Jason Jobe on 8/6/24.
//
import Foundation

/// A nil value is < than a non-nil value
extension String? {
    public static func < (lhs: String?, rhs: String?) -> Bool {
        switch (lhs, rhs) {
            case (nil, nil):
                return false
            case (nil, _):
                return true
            case (_, nil):
                return false
            case (let left, let right):
                return left < right
        }
    }
}

extension Array where Element: Comparable {
    public static func < (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
        for (left, right) in zip(lhs, rhs) {
            if left < right {
                return true
            } else if left > right {
                return false
            }
        }
        return lhs.count < rhs.count
    }
}
