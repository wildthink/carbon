import Foundation
@_exported import AnyCodable


public protocol EntityReference: Identifiable, Codable
where ID == MID64 { }
