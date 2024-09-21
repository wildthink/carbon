//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation

extension URL {
    
    public static let home: Self = {
        #if os(macOS)
        let passInfo = getpwuid(getuid())
        if let homeDir = passInfo?.pointee.pw_dir {
            let homePath = String(cString: homeDir)
            return URL(filePath: homePath)
        }
        #endif
        
//        let expanded = ("~/" as NSString).expandingTildeInPath

        let p = NSHomeDirectory()
        return URL(filePath: p)
        // jmj - skipping the isSandboxed check
//        if ProcessInfo.processInfo.entitlements.isSandboxed == false {
//            return p
//        } else {
//            // ~/Library/Containers/{bundle id}/Data
//            let homeComponents = p.components.dropLast(4)
//            return Path(Array(homeComponents))
//        }
    }()
    
}

prefix operator ~/

public prefix func ~/ (rhs: any StringProtocol) -> URL {
    return URL.home.appending(component: rhs)
}

extension FileManager {
    
    public func directoryExists(at url: URL) -> Bool {
        return self.folderExists(at: url)
    }
    
    public func createDirectory(at url: URL, withIntermediateDirectorys: Bool = true, attributes: [FileAttributeKey: Any]? = nil) throws {
        
        try self.createDirectory(atPath: url.path(percentEncoded: false),
                                 withIntermediateDirectories: withIntermediateDirectorys,
                                 attributes: attributes)
    }
    
    public func folderExists(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = self.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDir)
        return exists && isDir.boolValue == true
    }
    
    public func fileExists(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = self.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDir)
        return exists && isDir.boolValue == false
    }
    
    public func displayName(at url: URL) -> String {
        return self.displayName(atPath: url.path(percentEncoded: false))
    }
}
