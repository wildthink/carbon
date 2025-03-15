//
//  ValueContainer.swift
//  Carbon14
//
//  Created by Jason Jobe on 1/26/25.
//
// Modeled on https://github.com/swiftlang/swift-foundation
//  ...Sources/FoundationEssentials/AttributedString/AttributeContainer.swift

@dynamicMemberLookup
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public struct ValueContainer<Root> : Sendable {
    public typealias Store = [PartialKeyPath<Root>: AnyCodable]

    internal var storage : Store
    
    public init() {
        storage = .init()
    }
    
    internal init(_ storage: Store) {
        self.storage = storage
    }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension ValueContainer {

    @preconcurrency
    public subscript<K>(dynamicMember keyPath: KeyPath<Root, K>) -> K? where K : Sendable {
        get { storage[keyPath]?.value as? K }
//        set { self[K.self] = newValue }
    }

//    public subscript<S: AttributeScope>(dynamicMember keyPath: KeyPath<AttributeScopes, S.Type>) -> ScopedValueContainer<S> {
//        get {
//            return ScopedValueContainer(storage)
//        }
//        _modify {
//            var container = ScopedValueContainer<S>()
//            defer {
//                if let removedKey = container.removedKey {
//                    storage[removedKey] = nil
//                } else {
//                    storage.mergeIn(container.storage)
//                }
//            }
//            yield &container
//        }
//    }

//    public static subscript<K>(dynamicMember keyPath: KeyPath<Root, K>) -> Builder<K> {
//        return Builder(container: ValueContainer())
//    }
//
//    @_disfavoredOverload
//    public subscript<K>(dynamicMember keyPath: KeyPath<Root, K>) -> Builder<K> {
//        return Builder(container: self)
//    }
//
//    public struct Builder<T> : Sendable {
//        var container : ValueContainer
//
//        @preconcurrency
//        public func callAsFunction(_ value: T) -> ValueContainer where T : Sendable {
//            var new = container
//            new[T.self] = value
//            return new
//        }
//    }

//    public mutating func merge(_ other: ValueContainer, mergePolicy: AttributedString.AttributeMergePolicy = .keepNew) {
//        self.storage.mergeIn(other.storage, mergePolicy: mergePolicy)
//    }
//
//    public func merging(_ other: ValueContainer, mergePolicy:  AttributedString.AttributeMergePolicy = .keepNew) -> ValueContainer {
//        var copy = self
//        copy.merge(other, mergePolicy:  mergePolicy)
//        return copy
//    }
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension ValueContainer: Equatable {}

//@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
//extension ValueContainer: Hashable {}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension ValueContainer: CustomStringConvertible {
    public var description: String {
        storage.description
    }
}
