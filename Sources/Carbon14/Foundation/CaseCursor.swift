//
//  CaseCursor.swift
//  AppPackage
//
//  Created by Jason Jobe on 8/3/24.
//

import Foundation

public extension CaseIterable where Self: Equatable
{    
    static func array() -> [Self] {
        Array(Self.allCases)
    }
    
    // TODO: Add option to wrap or return nil
    func next() -> Self {
        let list = Self.allCases // Self.array()
        let ndx = list.firstIndex(of: self) ?? list.startIndex
        let next = list.index(after: ndx)
        return next < list.endIndex ? list[next] : list[list.startIndex]
    }
    
    func previous() -> Self {
        let list = Self.allCases // Self.array()
        let ndx = list.firstIndex(of: self) ?? list.endIndex
        let next = (ndx == list.startIndex)
        ? list.index(list.endIndex, offsetBy: -1)
        : list.index(ndx, offsetBy: -1)
        return list[next]
    }
    
}

public struct OptionSetIterator<Element: OptionSet, Value: FixedWidthInteger>: IteratorProtocol
where Element.RawValue == Value
{
    private let value: Element
    
    public init(element: Element) {
        self.value = element
    }
    
    private lazy var remainingBits = value.rawValue
    private var bitMask: Value = 1
    
    public mutating func next() -> Element? {
        while remainingBits != .zero {
            defer { bitMask = bitMask &* 2 }
            if remainingBits & bitMask != .zero {
                remainingBits = remainingBits & ~bitMask
                return Element(rawValue: bitMask)
            }
        }
        return nil
    }
}

extension OptionSet {
    public func makeIterator<I: FixedWidthInteger>()
    -> OptionSetIterator<Self,I>
    where Self.RawValue == I
    {
        return OptionSetIterator(element: self)
    }
}
