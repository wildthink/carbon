// Credits
// Random Generator
// https://gist.github.com/IanKeen/d3a22473a8f946bffce213a16e02dc2f
// EmptyDecoder
// https://gist.github.com/IanKeen/4348694dd62ac297ecf0d866164edb72
import Foundation

/// The `SafeDecoder` is designed to decode any "storage" that conforms
/// to `AnyDictionary` for keyed values, `AnyArray` for unkeyed containers
/// accessed by an Integer index, or `Decodable`. In addition, where reasonable
/// and possible, fundamental numeric, boolean, string, and Optional types are
/// always provided values when missing (or null) in the underlying storage value.
/// These being zero (0), false, "", and nil, respectively.
open class SafeDecoder: Decoder {
    public let codingPath: [CodingKey]
    public let userInfo: [CodingUserInfoKey: Any]
    var top: Any?
    
    public init<T>(from top: T, userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.top = top
        self.codingPath = []
        self.userInfo = userInfo
    }
    
    public func decode<D: Decodable>(
        _ ct: D.Type = D.self,
        from top: Any
    ) throws -> D {
        if let xf = SafeDecoder.decoders.first(where: { $0.canDecode(D.self) }) {
            return try xf.decode(value: top)
        } else {
            return try D(from: SafeDecoder(from: top, userInfo: userInfo))
        }
    }

    public func container<Key: CodingKey>(keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> {
        guard let dict = top as? AnyDictionary
        else { throw SafeDecoderError.unsupported(Swift.type(of: top)) }
        return .init(KeyedContainer<Key>(decoder: self, value: dict))
    }
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let array = (top as? AnyArray) ?? (top as? NSArray)
        else { throw SafeDecoderError.unsupported(type(of: top)) }
        return UnkeyedContainer(decoder: self, array: array)
    }
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(decoder: self, value: top)
    }
}

// MARK: associated public protocols
public protocol AnyDictionary {
    func value(forKey: String) -> Any?
}

public protocol AnyArray {
    var count: Int { get }
    func object(at: Int) -> Any
}

public protocol ContainerValue {
    static func emptyValue() -> Self
}

extension Array: ContainerValue {
    public static func emptyValue() -> Array<Element> { [] }
}


extension Dictionary: ContainerValue {
    public static func emptyValue() -> Dictionary<Key, Value> { [:] }
}

extension Set: ContainerValue {
    public static func emptyValue() -> Set<Element> { .init() }
}

extension NSDictionary: AnyDictionary {}
extension Dictionary: AnyDictionary where Key == String {
    public func value(forKey key: String) -> Any? {
        self[key]
    }
}

extension NSArray: AnyArray {}
extension Array: AnyArray {
    public func object(at ndx: Int) -> Any {
        self[ndx]
    }
}

extension Decodable {
    public static func empty() throws -> Self {
        switch Self.self {
            case is String.Type:
                "" as! Self
            case let f as ContainerValue.Type:
                f.emptyValue() as! Self
            default:
                try Self(from: SafeDecoder(from: NSDictionary()))
        }
    }
}

public enum SafeDecoderError: Error, Sendable {
    case notImplemented
    case unsupported(Any.Type)
    case illegalTransform(of: String, as: Any.Type, to: Any.Type)
    case unsupportedNestingContainer
    case superDecoderUnsupported
}

typealias ValueDecoderFn<Value> = (Any, [CodingUserInfoKey: Any]) throws -> Value

struct CustomValueDecoder {
    var valueType: Decodable.Type
    var _decode: ValueDecoderFn<Decodable>

    init<Value: Decodable>(_ valueType: Value.Type, fn: @escaping ValueDecoderFn<Value>) {
        _decode = fn
        self.valueType = Value.self
    }
    
    func canDecode<D: Decodable>(_ valueType: D.Type) -> Bool {
        valueType == self.valueType
    }
    
    func decode<Value: Decodable>(
        value: Any,
        as vt: Value.Type = Value.self,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) throws -> Value {
        guard let rv = try _decode(value, userInfo) as? Value
        else {
            throw SafeDecoderError.unsupported(Value.self)
        }
        return rv
    }
}

//extension SafeDecoder {
    /// A method  used to translate `DatabaseValue` into `Date`.
    public enum DateDecodingMethod {
        /// Defer to `Date` for decoding.
        case deferredToDate
        /// Decode the date as a floating-point number containing the interval between the date and 00:00:00 UTC on 1 January 1970.
        case timeIntervalSince1970
        /// Decode the date as a floating-point number containing the interval between the date and 00:00:00 UTC on 1 January 2001.
        case timeIntervalSinceReferenceDate
        /// Decode the date as ISO-8601 formatted text.
        case iso8601(ISO8601DateFormatter.Options)
        /// Decode the date as text parsed by the given formatter.
        case formatted(DateFormatter)
        /// Decode the date using the given closure.
        case custom((_ value: Any) throws -> Date)
    }
//}

extension DateDecodingMethod {
    enum DateDecodingError { case incompatableStorage(Any.Type) }
    
    func decodeDate(_ value: Any) throws -> Date {
        
        switch (self, value) {
            case (.deferredToDate, let v as any Decodable):
                return try Date(from: v as! Decoder)
                
            case (.timeIntervalSince1970, let v as Double):
                return Date(timeIntervalSince1970: v)
                
            case (.timeIntervalSinceReferenceDate, let v as Double):
                return Date(timeIntervalSinceReferenceDate: v)
                
//            case (.iso8601, let v as String):
//                throw SafeDecoderError.notImplemented
//
//            case (.formatted, let v as String):
//                throw SafeDecoderError.notImplemented

            case (.custom(let closure), _):
                return try closure(value)
            default:
                throw SafeDecoderError.unsupported(Swift.type(of: value))
        }
    }
}

extension SafeDecoder {
    nonisolated(unsafe) static var decoders: [CustomValueDecoder] = [
        CustomValueDecoder(Date.self) { (v, info) in
            // TODO: Lookup Date options from UserInfo
            let dateDecodingMethod: DateDecodingMethod =
                info[.dateDecodingMethod] as? DateDecodingMethod
                ?? .deferredToDate
            
            return switch v {
                case let v as Date: v
                case let v as any FixedWidthInteger:
                    Date(timeIntervalSince1970: Double(v))
                case let v as TimeInterval:
                    Date(timeIntervalSince1970: v)
                default:
                    throw SafeDecoderError.unsupported(Date.self)
            }
        }
    ]
    
    public static func decode<D: Decodable>(
        _ ct: D.Type = D.self,
        from top: Any,
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) throws -> D {
        if let xf = decoders.first(where: { $0.canDecode(D.self) }) {
            return try xf.decode(value: top)
        } else {
            return try D(from: SafeDecoder(from: top, userInfo: userInfo))
        }
    }
}

public extension CodingUserInfoKey {
    static let dateDecodingMethod = CodingUserInfoKey(rawValue: "dateDecodingMethod")!
}

// MARK: - SafeDecoder Containers
extension SafeDecoder {
    struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        let allKeys: [Key] = []
        let codingPath: [CodingKey] = []
        let value: AnyDictionary?
        let decoder: SafeDecoder
//        let userInfo: [CodingUserInfoKey: Any]
        
        init(decoder: SafeDecoder, value: AnyDictionary?) {
            self.decoder = decoder
            self.value = value
//            self.userInfo = userInfo
        }
        
        func contains(_ key: Key) -> Bool {
            return true
        }
        func decodeNil(forKey key: Key) throws -> Bool {
            return true
        }
        func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            if let val = value?.value(forKey: key.stringValue) {
                return try decoder.decode(from: val)
            }
            return try T.empty()
        }
        
        func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
            let val = value?.value(forKey: key.stringValue) as? AnyDictionary
            ?? NSDictionary()
            return .init(KeyedContainer<NestedKey>(decoder: decoder, value: val))
        }
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            let val = value?.value(forKey: key.stringValue) as? AnyArray
            ?? NSArray()
            return UnkeyedContainer(decoder: decoder, array: val)
        }
        func superDecoder() throws -> Decoder {
            throw SafeDecoderError.superDecoderUnsupported
        }
        func superDecoder(forKey key: Key) throws -> Decoder {
            throw SafeDecoderError.superDecoderUnsupported
        }
    }
    
    struct SingleValueContainer: SingleValueDecodingContainer {
        let decoder: SafeDecoder
        let codingPath: [CodingKey] = []
        var value: Any
        
        init<A>(decoder: SafeDecoder, value: A) {
            self.decoder = decoder
            self.value = value
        }

        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            switch value {
                case let v as T: return v
                case let v as Data:
                    return try JSONDecoder().decode(T.self, from: v)
                case let v as String:
                    if let data = v.data(using: .utf8) {
                        let dc = JSONDecoder()
                        return try dc.decode(T.self, from: data)
                    } else {
                        return try T.empty()
                    }
                default:
                    return try T.empty()
            }
        }

        func decodeNil() -> Bool { return true }
        func decode(_ type: Bool.Type)   throws -> Bool   { (value as? Bool) ?? false }
        func decode(_ type: String.Type) throws -> String { (value as? String) ?? "" }
        
        func decode(_ type: Double.Type) throws -> Double { (value as? Double) ?? 0 }
        func decode(_ type: Float.Type)  throws -> Float  { (value as? Float) ?? 0 }
        
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
        
        // A convenience method - helpful when storing "all ints" in a common format
        func decodeInt<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
            if let ns = value as? NSNumber {
                return T(ns.int64Value)
            } else {
                return (value as? T) ?? T(0)
            }
        }
    }
}

struct UnkeyedContainer: UnkeyedDecodingContainer {
    
    var codingPath: [any CodingKey] = []
    var count: Int?
    var isAtEnd: Bool { currentIndex >= array.count - 1 }
    var currentIndex: Int
    var array: AnyArray
//    var userInfo: [CodingUserInfoKey: Any]
    var decoder: SafeDecoder
    var value: Any {
        mutating get throws {
            defer { currentIndex += 1 }
            return array.object(at: currentIndex)
        }
    }
    
    init(decoder: SafeDecoder, array: AnyArray, codingPath: [any CodingKey] = []) {
        self.codingPath = codingPath
        self.array = array
        self.count = array.count
        self.currentIndex = 0
        self.decoder = decoder
    }
    
    func decodeNil() -> Bool {
        return false
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let v = try value
        if let h = v as? T { return h }
        let h = try T(from: SafeDecoder(from: v)) // FIXME
        if Swift.type(of: v) != Swift.type(of: h) {
            throw SafeDecoderError.illegalTransform(
                of: String(describing: v), as: Swift.type(of: v), to: Swift.type(of: h))
        }
        return h
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw SafeDecoderError.unsupportedNestingContainer
    }
    
    func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        throw SafeDecoderError.unsupportedNestingContainer
    }
    
    func superDecoder() throws -> any Decoder {
        throw SafeDecoderError.superDecoderUnsupported
    }
}

/*
/// The `BaseSingleValueContainer` always returns a default value when the underlying
/// storage value is missing for the basic types. Zero for all numeric types, `false` for Bools,
/// and the empty string.
public protocol BaseSingleValueContainer: SingleValueDecodingContainer {

    var value: Any { get }
    func decodeNil() -> Bool
    func decode(_ type: Bool.Type)   throws -> Bool
    func decode(_ type: String.Type) throws -> String
    
    func decode(_ type: Double.Type) throws -> Double
    func decode(_ type: Float.Type)  throws -> Float
    
    func decode(_ type: Int.Type)    throws -> Int
    func decode(_ type: Int8.Type)   throws -> Int8
    func decode(_ type: Int16.Type)  throws -> Int16
    func decode(_ type: Int32.Type)  throws -> Int32
    func decode(_ type: Int64.Type)  throws -> Int64
    func decode(_ type: UInt.Type)   throws -> UInt
    func decode(_ type: UInt8.Type)  throws -> UInt8
    func decode(_ type: UInt16.Type) throws -> UInt16
    func decode(_ type: UInt32.Type) throws -> UInt32
    func decode(_ type: UInt64.Type) throws -> UInt64
    
    // A convenience method - helpful when storing "all ints" in a common format
    func decodeInt<T: FixedWidthInteger>(_ type: T.Type) throws -> T
}

public extension BaseSingleValueContainer {
    
    func decodeNil() -> Bool { return true }
    func decode(_ type: Bool.Type)   throws -> Bool   { (value as? Bool) ?? false }
    func decode(_ type: String.Type) throws -> String { (value as? String) ?? "" }
    
    func decode(_ type: Double.Type) throws -> Double { (value as? Double) ?? 0 }
    func decode(_ type: Float.Type)  throws -> Float  { (value as? Float) ?? 0 }
    
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
    
    // A convenience method - helpful when storing "all ints" in a common format
    func decodeInt<T: FixedWidthInteger>(_ type: T.Type) throws -> T {
        if let ns = value as? NSNumber {
            return T(ns.int64Value)
        } else {
            return (value as? T) ?? T(0)
        }
    }
}
*/
