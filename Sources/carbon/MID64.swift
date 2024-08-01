//
//  MID64.swift
//  
//
//  Created by Jason Jobe on 1/15/24.
//

import Foundation

/// The MID64 is a simple UUID generator that fits into 64 bits
/// that provides acceptable performance on a given machine.
public struct MID64: Codable, Hashable, Equatable, Comparable, Sendable {
    
    public let value: UInt64
    public var timestamp: Date { value.extractDate() }
    public var counter: Int { Int((value << timestampBits) >> timestampBits) }
    public var tag: Int { Int((value << (64-tagBits)) >> (64-tagBits)) }

    public init(_ value: UInt64) {
        self.value = value
    }
    
    public init(tag: UInt8 = 0) {
        self.value = MID64Generator.shared.generateID(tag: tag)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(UInt64.self)
    }
        
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
    public static func < (lhs: MID64, rhs: MID64) -> Bool {
        lhs.value < rhs.value
    }
    public static func new(tag: UInt8 = 0) -> MID64 { .init(tag: tag) }
    public static let null: MID64 = 0
}

fileprivate let timestampBits = 48
fileprivate let counterBits = 16
fileprivate let tagBits = 4

extension MID64: CustomStringConvertible {
    public var description: String {
        String(value)
    }
}

extension MID64: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt64) {
        self.value = value
    }
}

public class MID64Generator {
    nonisolated(unsafe) public static var shared: MID64Generator = .init()
    
    private var lastTimestamp: UInt64 = 0
    private var counter: UInt16 = 0
    private let epoch: UInt64 = 1577836800000 // January 1, 2020, in milliseconds
    private let lock = NSLock()
    
    public init() {}
    
    public func generateID(tag: UInt8 = 0) -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        
        let currentTimestamp = UInt64(Date().timeIntervalSince1970 * 1000) - epoch
        
        if currentTimestamp != lastTimestamp {
            lastTimestamp = currentTimestamp
            counter = 0
        } else {
            counter &+= 1
        }
        
        let id = (lastTimestamp << (64-timestampBits))
            | UInt64(counter << tagBits)
            | UInt64(tag)
        return id
    }
}

extension UInt64 {
    private var epoch: UInt64 { 1577836800000 } // January 1, 2020, in milliseconds
    
    public func extractDate() -> Date {
        let timestamp = (self >> (64-timestampBits)) + epoch
        return Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
}

public extension FixedWidthInteger {
    
    var bytes:[UInt8] {
        var bigEndianValue = self.bigEndian
        let byteCount = MemoryLayout<Self>.size
        var byteArray: [UInt8] = []
        for _ in 0..<byteCount {
            byteArray.append(UInt8(bigEndianValue & 0xff))
            bigEndianValue >>= 8
        }
        return byteArray.reversed()
    }
    
    init?(bytes: [UInt8]) {
        guard bytes.count == MemoryLayout<Self>.size else {
            // Invalid byte array length for conversion
            return nil
        }
        var value: Self = 0
        for byte in bytes {
            value <<= 8
            value |= Self(byte)
        }
        self = value
    }
}
