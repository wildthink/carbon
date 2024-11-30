//
//  Symbol.swift
//  Carbon
//
//  Created by Jason Jobe on 8/5/24.
//  Created by Dave DeLong on 4/4/23.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
#if os(macOS)
import AppKit
#endif

#if canImport(SwiftDraw)
//  https://github.com/swhitty/SwiftDraw.git
import SwiftDraw
#endif


/*
 Jake’s SwiftUI Gotchas
 - Always define an SF Symbol with the SwiftUI.Image initializer, do not use
   a UIImage or NSImage with symbol configurations as those will not be honored.
 - Always use font (size and weight) and imageScale modifiers when attempting
   to adjust the size of the symbol in relation to other text
 - Never use the resizable() modifier on SF Symbols. Basically ever.
 - And also do not use .scaleToFit() / .aspectRatio() on them either.
 
 Bonus
 - If using an icon-only button, still declare the title of
   the button’s label and use .labelStyle(.iconOnly) for some
   great accessibility wins
 */
public struct Symbol {
    
    public enum SymbolSource {
        case image(PlatformImage)
        case swatch(AnyShapeStyle)
        case systemName(String)
        case named(String, Bundle?)
        case imageView(SwiftUI.Image)
#if canImport(SwiftDraw)
        case svgNamed(String)
        case svg(Data)
#endif
    }
    
    public let sourceProvider: () -> SymbolSource
    
    public init(sourceProvider: @escaping () -> SymbolSource) {
        self.sourceProvider = sourceProvider
    }
    
    public init(image: PlatformImage) {
        self.sourceProvider = { .image(image) }
    }

    public init(swatch: any ShapeStyle) {
        self.sourceProvider = { .swatch(.init(swatch)) }
    }

    public init(systemName: String) {
        self.sourceProvider = { .systemName(systemName) }
    }
    
    public init(named: String, bundle: Bundle? = nil) {
        self.sourceProvider = { .named(named, bundle) }
    }
    
}

extension Symbol {
    
    public static func icon(_ name: String, in bundle: Bundle? = nil) -> Self {
        self.init(sourceProvider: { .named(name, bundle) })
    }
    
    public static func systemName(_ name: String) -> Self {
        self.init(sourceProvider: { .systemName(name) })
    }
    
    public static func image(_ image: PlatformImage) -> Self {
        self.init(sourceProvider: { .image(image) })
    }
    
    public static func swatch(_ swatch: any ShapeStyle) -> Self {
        self.init(sourceProvider: { .swatch(.init(swatch)) })
    }

    #if os(macOS)
    public static func fileType(_ type: UTType) -> Self {
        self.init(sourceProvider: {
            let img = NSWorkspace.shared.icon(for: type)
            return .image(img)
        })
    }
    
    public static func fileIcon(_ url: URL) -> Self {
        self.init(sourceProvider: {
            let img = NSWorkspace.shared.icon(forFile: url.path())
            return .image(img)
        })
    }
        
    public static func application(_ bundleID: String) -> Self {
        self.init(sourceProvider: {
            if let u = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                return .image(NSWorkspace.shared.icon(forFile: u.path(percentEncoded: false)))
            }
            return .systemName("questionmark.app")
        })
    }
    #endif
}

extension Symbol: View {
    public var body: some View {
        Image(symbol: self)
    }
    
}

struct SymbolView: View {
    var symbol: Symbol
    
    var body: some View {
        switch symbol.sourceProvider() {
            case .systemName(let sf):
                Image(systemName: sf)
            case .named(let name, let bundle):
                Image(name, bundle: bundle)
            case .image(let img):
                Image(platformImage: img)
            case .swatch(let style):
                RoundedRectangle(cornerRadius: 8)
                    .fill(style)
            case .imageView(let imgView):
                imgView
#if canImport(SwiftDraw)
            case .svgNamed(let name):
                Image(svgNamed: name, bundle: .main)
            case .svg(let data):
                Image(svgData: data)
#endif
        }
    }
}

extension Image {
    
    public init(symbol: Symbol) {
        switch symbol.sourceProvider() {
        case .systemName(let sf):
            self.init(systemName: sf)
        case .named(let name, let bundle):
            self.init(name, bundle: bundle)
        case .image(let img):
            self.init(platformImage: img)
        case .swatch(let style):
            let sz = CGSize(width: 100, height: 100)
            self = Image(size: sz) { context in
                    context.fill(
                        Path(
                            roundedRect: CGRect(origin: .zero, size: sz),
                            cornerRadius: 0,
                            style: .continuous),
                        with: .style(style)
                    )
                }
            case .imageView(let imgView):
            self = imgView
#if canImport(SwiftDraw)
        case .svgNamed(let name):
            self.init(svgNamed: name, bundle: .main)
        case .svg(let data):
            self.init(svgData: data)
#endif
        }
    }
    
#if canImport(SwiftDraw)
    
    public init?(svgNamed: String, bundle: Bunle = .main) {
#if os(macOS)
        self = UIImage(svgNamed: svgNamed, bundle: bundle)
#else
        self = NSImage(svgNamed: svgNamed, bundle: bundle)
#endif
    }
    
    public init?(svgData: Data) {
#if os(macOS)
        self = UIImage(svgData: svgData)
#else
        self = NSImage(svgData: svgData)
#endif
    }

#endif
    
    public init(platformImage: PlatformImage) {
#if os(macOS)
        self.init(nsImage: platformImage)
#else
        self.init(uiImage: platformImage)
#endif
    }
    
}

extension LabeledContent where Content: View, Label == SwiftUI.Label<Text, Symbol> {

    public init(_ title: LocalizedStringKey, symbol: Symbol, content: () -> Content) {
        self.init(content: content, label: ({ SwiftUI.Label(title, symbol: symbol) }))
    }
}

extension Label where Title == Text, Icon == Symbol {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol) {
        self.init(title: { Text(titleKey) }, icon: { symbol })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol) where S : StringProtocol {
        self.init(title: { Text(title) }, icon: { symbol })
    }
    
}


extension Menu where Label == SwiftUI.Label<Text, Symbol> {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, @ViewBuilder content: () -> Content) {
        self.init(content: content, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(content: content, label: { Label(title, symbol: symbol) })
    }
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, @ViewBuilder content: () -> Content, primaryAction: @escaping () -> Void) {
        self.init(content: content, label: { Label(titleKey, symbol: symbol) }, primaryAction: primaryAction)
    }
}

#if os(macOS)
extension MenuBarExtra where Label == SwiftUI.Label<Text, Symbol> {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, isInserted: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.init(isInserted: isInserted, content: content, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, isInserted: Binding<Bool>, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(isInserted: isInserted, content: content, label: { Label(title, symbol: symbol) })
    }
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, @ViewBuilder content: () -> Content) {
        self.init(content: content, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(content: content, label: { Label(title, symbol: symbol) })
    }
}
#endif

extension Picker where Label == SwiftUI.Label<Text, Symbol> {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
        self.init(selection: selection, content: content, label: { Label(titleKey, symbol: symbol) })
    }
    
    public init<C>(_ titleKey: LocalizedStringKey, symbol: Symbol, sources: C, selection: KeyPath<C.Element, Binding<SelectionValue>>, @ViewBuilder content: () -> Content) where C : RandomAccessCollection, C.Element == Binding<SelectionValue> {
        self.init(sources: sources, selection: selection, content: content, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.init(selection: selection, content: content, label: { Label(title, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<C, S>(_ title: S, symbol: Symbol, sources: C, selection: KeyPath<C.Element, Binding<SelectionValue>>, @ViewBuilder content: () -> Content) where C : RandomAccessCollection, S : StringProtocol, C.Element == Binding<SelectionValue> {
        self.init(sources: sources, selection: selection, content: content, label: { Label(title, symbol: symbol) })
    }
}

extension Toggle where Label == SwiftUI.Label<Text, Symbol> {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, isOn: Binding<Bool>) {
        self.init(isOn: isOn, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, isOn: Binding<Bool>) where S : StringProtocol {
        self.init(isOn: isOn, label: { Label(title, symbol: symbol) })
    }
    
    public init<C>(_ titleKey: LocalizedStringKey, symbol: Symbol, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where C : RandomAccessCollection {
        self.init(sources: sources, isOn: isOn, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S, C>(_ title: S, symbol: Symbol, sources: C, isOn: KeyPath<C.Element, Binding<Bool>>) where S : StringProtocol, C : RandomAccessCollection {
        self.init(sources: sources, isOn: isOn, label: { Label(title, symbol: symbol) })
    }
}

extension Button where Label == SwiftUI.Label<Text, Symbol> {
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, action: @escaping () -> Void) {
        self.init(action: action, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, action: @escaping () -> Void) where S : StringProtocol {
        self.init(action: action, label: { Label(title, symbol: symbol) })
    }
    
    public init(_ titleKey: LocalizedStringKey, symbol: Symbol, role: ButtonRole?, action: @escaping () -> Void) {
        self.init(role: role, action: action, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<S>(_ title: S, symbol: Symbol, role: ButtonRole?, action: @escaping () -> Void) where S : StringProtocol {
        self.init(role: role, action: action, label: { Label(title, symbol: symbol) })
    }
}

extension ControlGroup {
    
    public init<C>(_ titleKey: LocalizedStringKey, symbol: Symbol, @ViewBuilder content: () -> C) where Content == LabeledControlGroupContent<C, Label<Text, Symbol>>, C : View {
        self.init(content: content, label: { Label(titleKey, symbol: symbol) })
    }
    
    @_disfavoredOverload
    public init<C, S>(_ title: S, symbol: Symbol, @ViewBuilder content: () -> C) where Content == LabeledControlGroupContent<C, Label<Text, Symbol>>, C : View, S : StringProtocol {
        self.init(content: content, label: { Label(title, symbol: symbol) })
    }
}
