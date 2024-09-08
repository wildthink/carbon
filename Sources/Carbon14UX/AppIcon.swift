//
//  AppIcon.swift
//  Improv
//
//  Created by Jason Jobe on 6/5/24.
//

import SwiftUI

//@MainActor
public struct Icon {
    public let name: String
    public let bundle: Bundle = .main
}

public extension Icon {
    
    @MainActor static var appIcon: Icon =
    Icon(name: Bundle.main.iconFileName)
    
    @MainActor static var appFullsizeIcon: Icon =
        Icon(name: "AppIcon")
}


#if canImport(UIKit)
import UIKit
public extension Icon {
    var image: Image {
        guard let img = UIImage(named: name)
        else { return Image(systemName: name) }
        return Image(uiImage: img)
    }
}

//extension Image {
//    public init?(data: Data) {
//        guard let imgp = UIImage(data: data)
//        else { return nil }
//        self = Image(uiImage: imgp)
//    }
//}

#endif

#if canImport(Cocoa)
import Cocoa
public extension Icon {
    var image: Image {
        guard let img = NSImage(named: name)
        else { return Image(systemName: name) }
        return Image(nsImage: img)
    }
}

extension Image {
    public init?(data: Data) {
        guard let imgp = NSImage(data: data)
        else { return nil }
        self = Image(nsImage: imgp)
    }
}

#endif


extension Image {
    public init(icon: Icon) {
        self = icon.image
    }
}

// MARK: AppIcon
public struct AppIcon: View {
    var borderRadius: CGFloat
    var fullSize: Bool
    var borderShape: some InsettableShape {
        RoundedRectangle(cornerRadius: borderRadius)
    }
    
    public init(
        borderRadius: CGFloat = 8,
        fullSize: Bool = false
    ) {
        self.borderRadius = borderRadius
        self.fullSize = fullSize
    }
    
    public var body: some View {
        Group {
            if fullSize {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                image
            }
        }
        .compositingGroup()
        .cornerRadius(borderRadius)
        .shadow(radius: 3, x: 3, y: 3)
    }

    public var image: Image {
        // TBD
//        Image()
//        Image(systemName: "photo")
        fullSize ? Icon.appFullsizeIcon.image : Icon.appIcon.image
    }
}

extension Bundle {
    var iconFileName: String {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return "AppIcon" }
        return iconFileName
    }
}


//#Preview {
//    Image("photo", bundle: .module)
////    AppIcon()
////        .frame(width: 200)
//}
