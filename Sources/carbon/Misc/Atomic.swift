//
//  Atomic.swift
//  Carbon
//
//  Created by Jason Jobe on 8/5/24.
//  Created by Dave DeLong on 7/10/23.
//

import Foundation

public final class Atomic<T> {
    private let _lock = NSLock()
    private var _value: T
    
    public init(_ value: T) {
        _value = value
    }
    
    public func with<U>( _ value: (inout T) -> U) -> U {
        _lock.lock()
        let returnValue = value(&_value)
        _lock.unlock()
        return returnValue
    }
    
    public func modify( _ modify: (T) -> T) {
        _lock.lock()
        _value = modify(_value)
        _lock.unlock()
    }
    
    @discardableResult
    public func swap(_ value: T) -> T {
        _lock.lock()
        let current = _value
        _value = value
        _lock.unlock()
        return current
    }
    
    public var value: T {
        get {
            _lock.lock()
            let value = _value
            _lock.unlock()
            return value
        }
        set {
            _lock.lock()
            _value = newValue
            _lock.unlock()
        }
    }
}
