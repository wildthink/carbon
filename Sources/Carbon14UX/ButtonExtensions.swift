//
//  File.swift
//  Carbon14
//
//  Created by Jason Jobe on 8/28/24.
//

import SwiftUI
#if canImport(Carbon14)
import Carbon14

public extension Button {
    init (intent: Intent) where Label == SwiftUI.Label<Text,Image> {
        self.init(action: intent.fn) {
            SwiftUI.Label(intent.title, systemImage: intent.symbol)
        }
    }
}
#endif

