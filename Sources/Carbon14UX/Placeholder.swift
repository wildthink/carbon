//
//  Placeholder.swift
//  SurfboardPackage
//
//  Created by Jason Jobe on 9/1/24.
//
import SwiftUI

extension Placeholder where Model: Identifiable {
    public init(@ViewBuilder content: @escaping (Model) -> Content) {
        self.content = content
    }
}

public struct Placeholder<Model, Content:View>: View {
    var model: Model?
    @ViewBuilder var content: (Model) -> Content
    
    public init(model: Model? = nil, content: @escaping (Model) -> Content) {
        self.model = model
        self.content = content
    }
    
    public var body: some View {
        if let model {
            content(model)
        } else {
            placeholder()
        }
    }
    
    @ViewBuilder
    func placeholder(_ name: String = String(describing: Model.self)) -> some View {
        
        VStack {
            Text("Placeholder")
            Text(name)
        }
    }
}

public extension Placeholder where Model == StringLiteralType, Content == AnyView {
    init(_ model: Model) {
        self.model = model
        self.content = { m in AnyView(Text(m)) }
    }
}
