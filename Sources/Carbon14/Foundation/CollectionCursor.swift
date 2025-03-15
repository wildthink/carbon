//
//  CollectionCursor.swift
//  Toolchain
//
//  Created by Jason Jobe on 12/5/24.
//
/// A cursor provides realive indexing into another collection.
///
/// A cursor stores a base collection and an Index into it.
/// It does not copy the elements from the collection into separate storage.
/// Thus, creating a cursor has O(1) complexity.
///
/// Cursor has relative subscripting
/// --------------------
///
/// Cursor Inherit Semantics
/// ------------------------
///
/// A cursor inherits the value or reference semantics of its base collection.
/// That is, if a `Cursor` instance is wrapped around a mutable collection that
/// has value semantics, such as an array, mutating the original collection
/// would trigger a copy of that collection, and not affect the base
/// collection stored inside of the slice.
///
/// Use cursors only for transient computation. A cursor may hold a reference to
/// the entire storage of a larger collection, not just to the portion it
/// presents, even after the base collection's lifetime ends. Long-term
/// storage of a cursor may therefore prolong the lifetime of elements that are
/// no longer otherwise accessible, which can erroneously appear to be memory
/// leakage.
///
/// - Note: Using a `Cursor` instance with a mutable collection requires that
///   the base collection's `subscript(_: Index)` setter does not invalidate
///   indices. If mutations need to invalidate indices in your custom
///   collection type, don't use `Cursor` as its subsequence type. Instead,
///   define your own subsequence type that takes your index invalidation
///   requirements into account.
///   https://github.com/swiftlang/swift/blob/dd978623053f986cfe7f8eb3812d6af0d81b549b/stdlib/public/core/Slice.swift#L83
@frozen // generic-performance
public struct Cursor<Base: RandomAccessCollection> {
    public var _currentIndex: Base.Index
    
    @usableFromInline // generic-performance
    internal var _base: Base
    
    /// Creates a view into the given collection that allows access to elements
    /// within the relative range.
    ///
    /// - Parameters:
    ///   - base: The collection to create a view into.
    ///   - bounds: The range of indices to allow access to in the new slice.
    @inlinable // generic-performance
    public init(base: Base, start: Base.Index) {
        self._base = base
        self._currentIndex = start
    }
    
    /// The underlying collection of the slice.
    ///
    @inlinable // generic-performance
    public var base: Base {
        return _base
    }
    
    public var isFirst: Bool {
        _currentIndex == _base.startIndex
    }

    public var isLast: Bool {
        let n = _base.index(after: _currentIndex)
        return n == _base.endIndex
    }

    public var canAdvance: Bool {
        _currentIndex < _base.endIndex
    }
    
    public func next() -> Self? {
        guard canAdvance else { return nil }
        let index = _base.index(after: _currentIndex)
        return Self(base: _base, start: index)
    }
}

extension Cursor: Sendable
where Base: Sendable, Base.Index: Sendable { }

extension Cursor where Base: MutableCollection {
    
    public subscript(offset: Int) -> Base.Element {
        get {
            let index = _base.index(_currentIndex, offsetBy: offset)
            //            _failEarlyRangeCheck(index, bounds: _bounds)
            return _base[index]
        }
        
        set {
            let index = _base.index(_currentIndex, offsetBy: offset)
            //            _failEarlyRangeCheck(index, bounds: _base.bounds)
            _base[index] = newValue
        }
    }
}

extension Cursor {
    public subscript(offset: Int) -> Base.Element {
        get {
            let index = _base.index(_currentIndex, offsetBy: offset)
            //            _failEarlyRangeCheck(index, bounds: _bounds)
            return _base[index]
        }
    }
}

public struct CursorIterator<Base: RandomAccessCollection>: Sequence, IteratorProtocol {
    var cursor: Cursor<Base>?
    
    public init(cursor: Cursor<Base>) {
        self.cursor = cursor
    }
    
    public mutating func next() -> Cursor<Base>? {
        guard let cursor, cursor.canAdvance
        else { return nil }
        defer {
            self.cursor = cursor.next()
        }
        return cursor
    }
}

//extension Slice {
//  @_alwaysEmitIntoClient
//  public __consuming func _copyContents(
//      initializing buffer: UnsafeMutableBufferPointer<Element>
//  ) -> (Iterator, UnsafeMutableBufferPointer<Element>.Index) {
//    if let (_, copied) = self.withContiguousStorageIfAvailable({
//      $0._copyContents(initializing: buffer)
//    }) {
//      let position = index(startIndex, offsetBy: copied)
//      return (Iterator(_elements: self, _position: position), copied)
//    }
//
//    return _copySequenceContents(initializing: buffer)
//  }
//}
/*
 
 extension Slice: RandomAccessCollection where Base: RandomAccessCollection { }
 */
