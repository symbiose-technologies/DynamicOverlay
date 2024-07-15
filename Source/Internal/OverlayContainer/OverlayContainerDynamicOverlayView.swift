//
//  OverlayContainerView.swift
//  DynamicOverlay
//
//  Created by Gaétan Zanella on 02/12/2020.
//  Copyright © 2020 Fabernovel. All rights reserved.
//

import SwiftUI

@Observable
public class DynamicOverlayContainerModel {
    
    public var activeScrollViewId: String?
    
    @ObservationIgnored
    var scrollProxyFrames: [String: DynamicOverlayScrollViewProxy] = [:]
    
    var activeScrollViewProxy: DynamicOverlayScrollViewProxy = .default
    
    public var behavior: DynamicOverlayBehaviorValue
    
    @ObservationIgnored
    public var activeScrollViewProxyItemId: String? = nil
    
    @ObservationIgnored
    var lastContainerUpdatedNotchIdx: Int? = nil
    
    @ObservationIgnored
    var lastExplicitCmdNotchIdx: Int? = nil
    
    private(set) public var trueActiveNotchIdx: Int? = nil
    
    
    func containerDidUpdateNotchIdxTo(idx: Int) {
        self.lastContainerUpdatedNotchIdx = idx
        debugPrint("[OVERLAY] Container Setting new active notch: \(idx) ")
        let isDiff = trueActiveNotchIdx != idx
        if isDiff {
            self.trueActiveNotchIdx = idx
            implicitlyChangedNotchCallbacks.forEach { (_, cb) in
                cb(idx)
            }
        }
    }
    
    public func explicitlySetActiveNotch(toIdx: Int) {
        let prev = lastExplicitCmdNotchIdx
        let isDiff = prev != toIdx
        debugPrint("Setting new active notch: \(toIdx) from curr: \(prev)")
        self.lastExplicitCmdNotchIdx = toIdx
        self.trueActiveNotchIdx = toIdx
        
    }
    
    
    public init(activeScrollViewId: String? = nil,
                behavior: DynamicOverlayBehaviorValue = .default) {
        self.activeScrollViewId = activeScrollViewId
        self.behavior = behavior
        debugPrint("[OVERLAY] init", activeScrollViewId ?? "nil")
        
    }
    
    func setScrollProxyFrames(_ scrollProxyFrames: [String: ActivatedOverlayArea]) {
        let curr = self.scrollProxyFrames
        for (id, area) in scrollProxyFrames {
            self.scrollProxyFrames[id] = DynamicOverlayScrollViewProxy(area: area)
        }
        let didChangeFrames = curr != self.scrollProxyFrames
        
        var didChangeActiveProxy = false
        
        
        //get active scroll view proxy
        let isDifferentIdFromApplied = activeScrollViewProxyItemId != activeScrollViewId
        
//        let isDifferentIdFromApplied = true1
        
        if isDifferentIdFromApplied {
            updateActiveScrollViewProxy()
            didChangeActiveProxy = true
        }
        
        //EDGE CASE WHERE THE PREVIOUS ACTIVE IS NO LONGER IN IT!!
        
        
//        if let activeScrollViewId = activeScrollViewId {
//            if let newActiveScrollViewProxy = self.scrollProxyFrames[activeScrollViewId] {
//                if newActiveScrollViewProxy != activeScrollViewProxy {
//                    activeScrollViewProxy = newActiveScrollViewProxy
//                    activeScrollViewProxyItemId = activeScrollViewId
//                    
//                    didChangeActiveProxy = true
//                }
//            }
//            
//        }
//        debugPrint("[OVERLAY] setScrollProxyFrames didChangeFrames", didChangeFrames, "didChangeActiveProxy", didChangeActiveProxy)
        
    }
    
    public func setBehavior(_ behavior: DynamicOverlayBehaviorValue) {
        self.behavior = behavior
    }
    
    
    public func setActiveScrollViewId(_ activeScrollViewId: String?) {
        let currActiveScrollViewId = self.activeScrollViewId
        let isDifferentFromSet = currActiveScrollViewId != activeScrollViewId
        
        let lastAppliedActiveScrollViewId = activeScrollViewProxyItemId
        let isDifferentFromApplied = lastAppliedActiveScrollViewId != activeScrollViewId
        debugPrint("[OVERLAY] setActiveScrollViewId", activeScrollViewId ?? "nil", "isDifferentFromSet", isDifferentFromSet, "isDifferentFromApplied", isDifferentFromApplied)
        
        if isDifferentFromSet {
            self.activeScrollViewId = activeScrollViewId
        }
        
        if isDifferentFromApplied || true {
            updateActiveScrollViewProxy()
        }
    }
    
    @ObservationIgnored
    private(set) public var lastTranslation: OverlayTranslation?
    
    @ObservationIgnored
    private(set) public var translationCallbacks: [String: (OverlayTranslation) -> Void] = [:]
    
    public func setTranslationCallback(cbId: String, callback: @escaping (OverlayTranslation) -> Void) {
        translationCallbacks[cbId] = callback
    }
    public func removeTranslationCallbackForId(_ cbId: String) {
        translationCallbacks.removeValue(forKey: cbId)
    }
    
    func onOverlayTranslationChange(translation: OverlayTranslation) {
        let lastTranslation = self.lastTranslation
        self.lastTranslation = translation
//        debugPrint("onOverlayTranslactionChange: \(translation)")
        self.triggerCallbacksWithTranslation(translation)
    }
    
    private func triggerCallbacksWithTranslation(_ translation: OverlayTranslation) {
        for (_, callback) in translationCallbacks {
            callback(translation)
        }
    }
    
    @ObservationIgnored
    private(set) public var implicitlyChangedNotchCallbacks: [String: (Int) -> Void] = [:]
    public func setImplicitlyChangedNotchCallback(cbId: String, callback: @escaping (Int) -> Void) {
        implicitlyChangedNotchCallbacks[cbId] = callback
    }
    public func removeImplicitlyChangedNotchCallbackForId(_ cbId: String) {
        implicitlyChangedNotchCallbacks.removeValue(forKey: cbId)
    }
    
    
    private func updateActiveScrollViewProxy() {
        if let activeScrollViewId = activeScrollViewId {
            if let newActiveScrollViewProxy = scrollProxyFrames[activeScrollViewId] {
                activeScrollViewProxy = newActiveScrollViewProxy
                activeScrollViewProxyItemId = activeScrollViewId
                
            }
        }
    }
    
}

struct SymOverlayContainerDynamicOverlayView<Background: View, Content: View>: View {

    @State
    private var dragArea: DynamicOverlayDragArea = .default

//    @State
//    private var scrollViewProxy: DynamicOverlayScrollViewProxy = .default

    
    private var scrollViewProxy: DynamicOverlayScrollViewProxy {
        model.activeScrollViewProxy
    }
    
    @State
    private var passiveContainer = OverlayContainerPassiveContainer()

    
    @Environment(\.behaviorValue)
    private var behavior: DynamicOverlayBehaviorValue
//    private var behavior: DynamicOverlayBehaviorValue { model.behavior }

    let model: DynamicOverlayContainerModel
    let background: Background
    let content: Content
    
    
    // MARK: - View

    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        
        SwiftUIOverlayContainerRepresentableAdaptor(
            adaptor: OverlayContainerRepresentableAdaptor(
                containerState: makeContainerState(),
                passiveContainer: passiveContainer,
                content: OverlayContentHostingView(),
                background: background,
                model: model
            )
        )
        .overlayContent(content.overlayCoordinateSpace())
        .onUpdate {
            passiveContainer.onTranslation = model.onOverlayTranslationChange(translation:)
            passiveContainer.onNotchChange = model.containerDidUpdateNotchIdxTo(idx:)
            
//            passiveContainer.onTranslation = behavior.block
            // This is tricky. `OverlayContainerPassiveContainer` is a class inside a struct,
            // `passiveContainer.onNotchChange = { self.behavior.binding?.wrappedValue = $0 }`
            // would create a retain cycle as `self` includes a ref to `passiveContainer`.
//            let behavior = behavior
//            passiveContainer.onNotchChange = { behavior.binding?.wrappedValue = $0 }
        }
//        .onDragAreaChange {
//            dragArea = $0
//        }
//        .onDrivingScrollViewChange {
//            scrollViewProxy = $0
//        }
        .onPreferenceChange(SymDynamicOverlayScrollViewProxyPreferenceKey.self, perform: { value in
//            debugPrint("SymDynamicOverlayScrollViewProxyPreferenceKey", value)
            model.setScrollProxyFrames(value)
        })
        
        .onPreferenceChange(SymDynamicOverlayDragAreaPreferenceKey.self, perform: { value in
//            debugPrint("SymDynamicOverlayDragAreaPreferenceKey", value)
        })
    }

    // MARK: - Private

    private func makeContainerState() -> OverlayContainerState {
        OverlayContainerState(
            dragArea: dragArea,
            drivingScrollViewProxy: scrollViewProxy,
            notchIndex: model.trueActiveNotchIdx ?? 0,
//            notchIndex: behavior.binding?.wrappedValue,
            disabledNotches: behavior.disabledNotchIndexes,
            layout: OverlayContainerLayout(indexToDimension: behavior.notchDimensions ?? [:])
        )
    }
}










struct OverlayContainerDynamicOverlayView<Background: View, Content: View>: View {

    @State
    private var dragArea: DynamicOverlayDragArea = .default

    @State
    private var scrollViewProxy: DynamicOverlayScrollViewProxy = .default

    @State
    private var passiveContainer = OverlayContainerPassiveContainer()

    @Environment(\.behaviorValue)
    private var behavior: DynamicOverlayBehaviorValue

    let background: Background
    let content: Content

    // MARK: - View

    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        
        #endif
        
        SwiftUIOverlayContainerRepresentableAdaptor(
            adaptor: OverlayContainerRepresentableAdaptor(
                containerState: makeContainerState(),
                passiveContainer: passiveContainer,
                content: OverlayContentHostingView(),
                background: background,
                model: nil
            )
        )
        .overlayContent(content.overlayCoordinateSpace())
        .onUpdate {
            passiveContainer.onTranslation = behavior.block
            // This is tricky. `OverlayContainerPassiveContainer` is a class inside a struct,
            // `passiveContainer.onNotchChange = { self.behavior.binding?.wrappedValue = $0 }`
            // would create a retain cycle as `self` includes a ref to `passiveContainer`.
            let behavior = behavior
            passiveContainer.onNotchChange = { behavior.binding?.wrappedValue = $0 }
        }
        .onDragAreaChange {
            dragArea = $0
        }
        .onDrivingScrollViewChange {
            scrollViewProxy = $0
        }
    }

    // MARK: - Private

    private func makeContainerState() -> OverlayContainerState {
        OverlayContainerState(
            dragArea: dragArea,
            drivingScrollViewProxy: scrollViewProxy,
            notchIndex: behavior.binding?.wrappedValue,
            disabledNotches: behavior.disabledNotchIndexes,
            layout: OverlayContainerLayout(indexToDimension: behavior.notchDimensions ?? [:])
        )
    }
}

private extension View {

    func onUpdate(_ block: () -> Void) -> some View {
        block()
        return self
    }
}
