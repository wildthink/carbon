//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/2/23.
//

import Foundation

public typealias BundleID<Base, RawValue> = Tagged<Base, RawValue>

extension Bundle {
    
    public var identifier: BundleID<Bundle, String>? {
        guard let bundleIdentifier else { return nil }
        return BundleID(rawValue: bundleIdentifier)
    }
    
    public var shortVersionString: String? {
        if let s = string(forInfoDictionaryKey: "CFBundleShortVersionString") { return s }
        return nil
    }
    
    public var versionString: String? {
        if let s = string(forInfoDictionaryKey: "CFBundleVersion") { return s }
        if let s = shortVersionString { return s }
        return ""
    }
    
    public var name: String {
        if let s = string(forInfoDictionaryKey: "CFBundleName") { return s }
        if let s = string(forInfoDictionaryKey: "CFBundleDisplayName") { return s }
        if let s = bundleIdentifier { return s }
        return bundleURL.lastPathComponent
    }
    
    public func string(forInfoDictionaryKey key: String) -> String? {
        return object(forInfoDictionaryKey: key) as? String
    }
    
    public var entitlementsDictionary: Dictionary<String, Any>? {
        [:]
//        if self == Bundle.main { return ProcessInfo.processInfo.entitlementsDictionary }
//        
//        guard let executableURL = self.executableURL else { return nil }
//        let path = Path(executableURL)
//        return ProcessInfo.entitlementsDictionary(for: path)
    }
    
    public var entitlements: Entitlements? {
        guard let dict = entitlementsDictionary else { return nil }
        return Entitlements(source: dict)
    }

}
