//
//  ActiveOverlayAreaViewModifier.swift
//  DynamicOverlay
//
//  Created by Gaétan Zanella on 28/12/2020.
//  Copyright © 2020 Fabernovel. All rights reserved.
//

import SwiftUI

struct ActiveOverlayAreaViewModifier<Key: PreferenceKey>: ViewModifier where Key.Value == ActivatedOverlayArea {

    let key: Key.Type
    let isActive: Bool

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Spacer().preference(
                    key: key,
                    value: isActive ? .active(proxy.frame(in: .overlay)) : .inactive()
                )
            }
        )
    }
}





struct SymActiveOverlayAreaViewModifier<Key: PreferenceKey>: ViewModifier where Key.Value == [String: ActivatedOverlayArea] {

    let id: String
    let key: Key.Type

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Spacer().preference(
                    key: key,
                    value: [id: .active(proxy.frame(in: .overlay)) ]
                    
                )
            }
        )
    }
}
