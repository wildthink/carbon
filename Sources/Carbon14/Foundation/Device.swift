//
//  Device.swift
//  ImprovPackage
//
//  Created by Jason Jobe on 1/6/25.
//
import SwiftUI
#if canImport(AppKit)
    import AppKit
#endif
#if canImport(UIKit)
    import UIKit
#endif

@MainActor
@propertyWrapper
public struct Device: DynamicProperty {
    
    public init() {}
    
    public var wrappedValue: DeviceInfo {
        DeviceInfo.current
    }
}

@dynamicMemberLookup
public struct DeviceInfo: Sendable {
    public enum Orientation: Sendable { case portrait, landscape }
    public nonisolated(unsafe)
    static var current: DeviceInfo = .init(deviceSettings: .laptopDesktop)
    
    public private(set) var orientation: Orientation = .landscape
    public var isPortrait:  Bool { orientation == .portrait }
    public var isLandscape: Bool { orientation == .landscape }
    public var isValidInterfaceOrientation: Bool { true }

    var deviceSettings: DeviceSettings
}

public extension DeviceInfo {
    subscript<V>(dynamicMember keyp: KeyPath<DeviceSettings, V>) -> V {
        deviceSettings[keyPath: keyp]
    }
}


public extension DeviceInfo {
#if DEBUG
    var isDebug: Bool { true }
    var isPreview: Bool {
        ProcessInfo.processInfo
            .environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
#else
    var isDebug:   Bool { false }
    var isPreview: Bool { false }
//        context.append("RELEASE")
#endif
        
        // Check for simulator
#if targetEnvironment(simulator)
    var isSimulator: Bool { true }
#else
    var isSimulator: Bool { false }
#endif

#if canImport(AppKit)
    func pbCopy(_ str: @autoclosure () -> String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(str(), forType: .string)
    }
#endif
    
#if canImport(UIKit)
    func pbCopy(_ str: @autoclosure () -> String) {
        let pb = UIPasteboard.general
        pb.string = str()
    }
#endif
}

public enum DeviceType: String, Sendable {
    case smartphone = "Smartphone"
    case tablet = "Tablet"
    case laptopDesktop = "Laptop/Desktop"
    case tv = "TV"
}

public enum ViewingDistance: String, Sendable {
    case close = "Close"
    case medium = "Medium"
    case far = "Far"
}

public struct DeviceSettings: Sendable {
    var deviceType: DeviceType
    var viewingDistance: ViewingDistance
    var imageResolution: String
    var fontSize: CGFloat
}

public extension DeviceSettings {
    static let smartphone = DeviceSettings(
        deviceType: .smartphone,
        viewingDistance: .medium, // Adjust default value as needed
        imageResolution: "720p", // Default resolution for smartphone
        fontSize: 16.0 // Default font size for smartphone
    )
    
    static let tablet = DeviceSettings(
        deviceType: .tablet,
        viewingDistance: .medium, // Adjust default value as needed
        imageResolution: "1080p", // Default resolution for tablet
        fontSize: 20.0 // Default font size for tablet
    )
    
    static let laptopDesktop = DeviceSettings(
        deviceType: .laptopDesktop,
        viewingDistance: .medium, // Adjust default value as needed
        imageResolution: "1440p", // Default resolution for laptop/desktop
        fontSize: 22.0 // Default font size for laptop/desktop
    )
    
    static let tv = DeviceSettings(
        deviceType: .tv,
        viewingDistance: .medium, // Adjust default value as needed
        imageResolution: "1080p", // Default resolution for TV
        fontSize: 26.0 // Default font size for TV
    )
}

#if os(iOS)
import SwiftUI
import Combine

@MainActor
@propertyWrapper
public struct Orientation: DynamicProperty {
    @StateObject var core = Core()
    
    public init() {}
    
    public var wrappedValue: UIDeviceOrientation {
        core.orientation
    }
}

extension UIDeviceOrientation: @retroactive CustomStringConvertible {
    public var description: String {
        return switch self {
            case .landscapeLeft: "LandscapeLeft"
            case .landscapeRight: "LandscapeRight"
            case .portrait: "Portrait"
            case .portraitUpsideDown: "portraitUpsideDown"
            case .faceUp: "faceUp"
            case .faceDown: "faceDown"
            case .unknown: "Unknown"
            @unknown default:
                "Unknown"
        }
    }
}
extension Orientation {
    @MainActor
    final class Core: ObservableObject {
        @Published var orientation: UIDeviceOrientation
        var handler: Cancellable?
        
        init() {
            orientation = UIDevice.current.orientation
            register()
        }
        
        func register() {
            guard handler == nil else { return }
            handler = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                .makeConnectable()
                .autoconnect()
                .sink { [weak self] n in
                    guard let self else { return }
                    if let device = n.object as? UIDevice {
                        self.orientation = device.orientation
                    }
                }
        }
    }
}
#endif
