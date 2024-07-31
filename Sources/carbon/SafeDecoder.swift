// Random Generator
// https://gist.github.com/IanKeen/d3a22473a8f946bffce213a16e02dc2f
// EmptyDecoder
// https://gist.github.com/IanKeen/4348694dd62ac297ecf0d866164edb72
import Foundation

public protocol AnyDictionary {
    func value(forKey: String) -> Any?
}

public protocol AnyArray {
    func object(at: Int) -> Any
}

extension NSDictionary: AnyDictionary {}
extension NSArray: AnyArray {}

extension Decodable {
    public static func empty() throws -> Self {
        return try Self(from: SafeDecoder(from: NSDictionary()))
    }
    
    public static func decode(from top: Any) throws -> Self {
        return try Self(from: SafeDecoder(from: top))
    }
}

enum SafeDecoderError: Error {
    case unsupported(Any.Type)
}

open class SafeDecoder: Decoder {
    public let codingPath: [CodingKey] = []
    public let userInfo: [CodingUserInfoKey: Any] = [:]
    // jmj
    var top: Any?
    
    public init(from top: Any? = nil) { self.top = top }
    
    public func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard let dict = top as? AnyDictionary
        else { throw SafeDecoderError.unsupported(Swift.type(of: top)) }
        return .init(KeyedContainer<Key>(value: dict))
    }
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let array = top as? AnyArray
        else { throw SafeDecoderError.unsupported(type(of: top)) }
        return UnkeyedContainer(value: array)
    }
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(value: top)
    }
}

// MARK: - SafeDecoder Containers
extension SafeDecoder {
    struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        let allKeys: [Key] = []
        let codingPath: [CodingKey] = []
        let value: AnyDictionary?
        
        init(value: AnyDictionary?) { self.value = value }
        
        func contains(_ key: Key) -> Bool {
            return true
        }
        func decodeNil(forKey key: Key) throws -> Bool {
            return true
        }
        func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            if let val = value?.value(forKey: key.stringValue) {
                return try T.decode(from: val)
            }
            return try T.empty()
        }
        
        func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
            let val = value?.value(forKey: key.stringValue) as? AnyDictionary
            ?? NSDictionary()
            return .init(KeyedContainer<NestedKey>(value: val))
        }
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            let val = value?.value(forKey: key.stringValue) as? AnyArray
            ?? NSArray()
            return UnkeyedContainer(value: val)
        }
        func superDecoder() throws -> Decoder {
            return SafeDecoder()
        }
        func superDecoder(forKey key: Key) throws -> Decoder {
            return SafeDecoder()
        }
    }
    
    struct UnkeyedContainer: UnkeyedDecodingContainer {
        let codingPath: [CodingKey] = []
        var count: Int? = 0
        var currentIndex: Int = 0
        var isAtEnd: Bool { return true }
        var value: AnyArray
        
        init(value: AnyArray) { self.value = value }
        
        mutating func decodeNil() throws -> Bool {
            return true
        }
        mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
            defer { self.currentIndex += 1 }
            return try T.decode(from: value.object(at: currentIndex))
            //            return try T.empty()
        }
        mutating func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
            defer { self.currentIndex += 1 }
            let val = value.object(at: currentIndex) as? AnyDictionary
            return .init(KeyedContainer<NestedKey>(value: val))
            //            return try .init(KeyedContainer<NestedKey>(value: .empty()))
        }
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            defer { self.currentIndex += 1 }
            let val = value.object(at: currentIndex) as? AnyArray ?? NSArray()
            return UnkeyedContainer(value: val)
        }
        mutating func superDecoder() throws -> Decoder {
            return SafeDecoder()
        }
    }
    struct SingleValueContainer: BaseSingleValueContainer {
        let codingPath: [CodingKey] = []
        var value: Any?
        
        init(value: Any? = nil) { self.value = value }
                
        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            if let v = value as? T { return v }
            if let v = value as? Data {
                let dc = JSONDecoder()
                return try dc.decode(T.self, from: v)
            }
            if let v = value as? String, let data = v.data(using: .utf8) {
                let dc = JSONDecoder()
                return try dc.decode(T.self, from: data)
            }
            return try T.empty()
        }
        
//        func decodeInt<T: FixedWidthInteger>(_ type: T.Type) throws -> T { (value as? T) ?? T(0) }
//
//        func decodeNil() -> Bool { return true }
//        func decode(_ type: Bool.Type) throws   -> Bool   { (value as? Bool) ?? false }
//        func decode(_ type: String.Type) throws -> String { (value as? String) ?? "" }
//        
//        func decode(_ type: Double.Type) throws -> Double { (value as? Double) ?? 0 }
//        func decode(_ type: Float.Type) throws  -> Float  { (value as? Float) ?? 0 }
    }
}

public protocol BaseSingleValueContainer: SingleValueDecodingContainer {
    var value: Any? { get }
}

public extension BaseSingleValueContainer {
    func decodeNil() -> Bool { return true }
    func decode(_ type: Bool.Type) throws   -> Bool   { (value as? Bool) ?? false }
    func decode(_ type: String.Type) throws -> String { (value as? String) ?? "" }
    
    func decode(_ type: Double.Type) throws -> Double { (value as? Double) ?? 0 }
    func decode(_ type: Float.Type) throws  -> Float  { (value as? Float) ?? 0 }
        
    func decode(_ type: Int.Type)    throws -> Int    { try decodeInt(type) }
    func decode(_ type: Int8.Type)   throws -> Int8   { try decodeInt(type) }
    func decode(_ type: Int16.Type)  throws -> Int16  { try decodeInt(type) }
    func decode(_ type: Int32.Type)  throws -> Int32  { try decodeInt(type) }
    func decode(_ type: Int64.Type)  throws -> Int64  { try decodeInt(type) }
    func decode(_ type: UInt.Type)   throws -> UInt   { try decodeInt(type) }
    func decode(_ type: UInt8.Type)  throws -> UInt8  { try decodeInt(type) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try decodeInt(type) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try decodeInt(type) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try decodeInt(type) }
    
    // jmj
    func decodeInt<T: FixedWidthInteger>(_ type: T.Type) throws -> T { (value as? T) ?? T(0) }
}

