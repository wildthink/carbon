//
//  Resource.swift
//  Carbib14
//
//  Created by Jason Jobe on 1/2/25.
//

import Foundation
import SwiftUI

public protocol ResourceKey<Value>: Equatable & Hashable {
    associatedtype Value
    var localKey: String { get }
    var valueType: Any.Type { get }
    var decoder: @Sendable (Data) throws -> Value { get }
}

extension ResourceKey {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.localKey == rhs.localKey
    }
}

@MainActor
@propertyWrapper
public struct Resource<Value>: @preconcurrency DynamicProperty
{
    public typealias Qualifier = CacheKey<Value>

    @StateObject private var tracker: Tracker<Value> = .init()
    var qualifier: Qualifier? {
        get { tracker.qualifier }
        nonmutating set { tracker.qualifier = newValue }
    }
    
    public var wrappedValue: Value {
        tracker.value ?? _wrappedValue
    }
    
    var _wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
    
    public mutating func update() {
        tracker.qualifier = self.qualifier
    }
    
    public var projectedValue: Tracker<Value> {
        tracker
    }
}


extension Resource {
    
    final public class Tracker<BoxValue>: ObservableObject, @unchecked Sendable {
        public typealias Qualifier = CacheKey<Value>

        var resource: DataLoader?
        
        public var qualifier: Qualifier? {
            get { _qualifier }
            set {
                guard newValue?.localKey != _qualifier?.localKey
                else { return }
                _qualifier = newValue
                reload()
            }
        }
        
        var _qualifier: Qualifier?
        
        public var value: BoxValue? {
            if let _cache { return _cache }
            load()
            return _cache
        }
        private var _cache: BoxValue?
        
        init(cacheKey: Qualifier? = nil) {
            if let cacheKey {
                self.qualifier = cacheKey
                // TODO: report exceptions
                resource = try? ResourceCache.shared.resource(key: cacheKey)
            }
        }
        
        func report(error: Error) {
            let url = (qualifier as? CacheKey<Value>)?.url.description ?? "<url>"
            print("Error loading \(url)\n\t: \(error.localizedDescription)")
        }
        
        @MainActor
        func resetCache(with data: Data) throws {
//            Task { @MainActor in
                let val = try qualifier?.decoder(data)
                if let cval = val as? BoxValue {
                    objectWillChange.send()
                    _cache = cval
                }
//            }
        }
        
        public func reload() {
            if let qualifier {
                do {
                    resource = try ResourceCache.shared.resource(key: qualifier)
                } catch {
                    report(error: error)
                }
            }
            load()
        }
        
        public func load() {
            guard let resource else { return }
            Task {
                do {
                    let data = try await resource.fetch()
                    try await resetCache(with: data)
                } catch {
                    report(error: error)
                }
            }
        }
    }
}
