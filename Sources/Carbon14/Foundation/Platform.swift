//
//  SwiftUIView.swift
//  
//
//  Created by Jason Jobe on 2/25/24.
//

public enum OSPlatform {
    case iOS, macOS
    
    public static var current: OSPlatform {
#if os(iOS)
        return .iOS
#elseif os(macOS)
        return .macOS
#endif
    }
}
