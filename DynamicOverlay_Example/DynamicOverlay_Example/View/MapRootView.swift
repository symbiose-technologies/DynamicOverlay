//
//  MapRootView.swift
//  DynamicOverlay_Example
//
//  Created by Gaétan Zanella on 17/04/2021.
//  Copyright © 2021 Fabernovel. All rights reserved.
//

import Foundation
import SwiftUI
import DynamicOverlay

enum Notch: CaseIterable, Equatable {
    case micro, min, max
}

struct MapRootView: View {

    struct State {
        var notch: Notch = .min
        var isEditing = false
        var progress = 0.0
    }

    @SwiftUI.State
    private var state = State()

    // MARK: - View

    var body: some View {
        let _ = Self._printChanges()
        
        
        background
            .dynamicOverlay(overlay)
            .dynamicOverlayBehavior(behavior)
            .ignoresSafeArea()

    }

    // MARK: - Private

    private var behavior: some DynamicOverlayBehavior {
        MagneticNotchOverlayBehavior<Notch> { notch in
            switch notch {
            case .max:
//                return .fractional(0.8)
                return .fractional(1.0)
            case .min:
                return .fractional(0.3)
            case .micro:
                return .absolute(80)
            }
        }
        .disable(.min, state.isEditing)
        .disable(.micro, state.isEditing)
        .notchChange($state.notch)
        .onTranslation { translation in
            state.progress = translation.progress
        }
    }

    private var background: some View {
        ZStack {
            MapView()
            BackdropView().opacity(state.progress)
        }
        .ignoresSafeArea()
    }

    private var overlay: some View {
        OverlayView { event in
            switch event {
            case .didBeginEditing:
                state.isEditing = true
                withAnimation { state.notch = .max }
            case .didEndEditing:
                state.isEditing = false
                withAnimation { state.notch = .min }
            }
        }
//        .scrollDismissesKeyboard(.interactively)
        
//        .ignoresSafeArea()
        .safeAreaInset(edge: .top, content: {
            Rectangle()
                .fill(Color.red)
                .frame(height: state.notch == .max ? 100 : 0)
                .ignoresSafeArea()
        })
        .ignoresSafeArea()

//        .drivingScrollView()
//        .dynamicOverlay(overlay2)
//        .dynamicOverlayBehavior(behavior2)
    }
    

}
