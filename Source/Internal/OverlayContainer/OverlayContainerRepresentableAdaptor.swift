//
//  OverlayContainerRepresentableAdaptor.swift
//  DynamicOverlayTests
//
//  Created by Gaétan Zanella on 20/04/2021.
//  Copyright © 2021 Fabernovel. All rights reserved.
//

import Foundation
import SwiftUI
import OverlayContainer


open class CustomOverlayContainerViewController: OverlayContainerViewController {
    
    // Define a private backing store for viewControllers
//    private var _viewControllers: [UIViewController] = []
//
//    
//    // Override topViewController to properly reflect the last view controller
//    open override var topViewController: UIViewController? {
//        return _viewControllers.last
//    }
//
//    
//    /// The view controllers displayed.
//    open override var viewControllers: [UIViewController] {
//        get {
//            debugPrint("[custom] didSet viewControllers", _viewControllers)
//            return _viewControllers
//        }
//        set {
//            debugPrint("[custom] didSet viewControllers", _viewControllers)
//            self._viewControllers = newValue
//            guard isViewLoaded else { return }
//            
//        }
////        didSet {
////            debugPrint("[custom] didSet viewControllers", viewControllers)
////            
////            guard isViewLoaded else { return }
//////            oldValue.forEach { removeChild($0) }
//////            loadOverlayViews()
////            setNeedsStatusBarAppearanceUpdate()
////        }
//    }

    open override func viewWillLayoutSubviews() {
        // (gz) 2019-06-10 According to the documentation, the default implementation of
        // `viewWillLayoutSubviews` does nothing.
        // Nethertheless in its `Changing Constraints` Guide, Apple recommends to call it.
//        defer {
//            super.viewWillLayoutSubviews()
//        }
        super.viewWillLayoutSubviews()

//        let hasNewHeight = previousSize.height != view.bounds.size.height
//        let hasPendingTranslation = translationController?.hasPendingTranslation() == true
//        guard needsOverlayContainerHeightUpdate || hasNewHeight else { return }
//        needsOverlayContainerHeightUpdate = false
//        previousSize = view.bounds.size
//        if hasNewHeight {
//            configuration.invalidateOverlayMetrics()
//        }
//        if hasNewHeight && !hasPendingTranslation {
//            translationController?.scheduleOverlayTranslation(
//                .toLastReachedNotchIndex,
//                velocity: .zero,
//                animated: false
//            )
//        }
//        configuration.requestOverlayMetricsIfNeeded()
//        performDeferredTranslations()
    }
    
//    open override func loadView() {
//        view = PassThroughView()
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        loadContainerViews()
////        loadOverlayViews()
//    }

    
//    open override func moveOverlay(toNotchAt index: Int, animated: Bool, completion: (() -> Void)? = nil) {
//        debugPrint("[custom] moveOverlay toNotchAt", index)
//
////        loadViewIfNeeded()
////        translationController?.scheduleOverlayTranslation(
////            .toIndex(index),
////            velocity: .zero,
////            animated: animated,
////            completion: completion
////        )
////        setNeedsOverlayContainerHeightUpdate()
//    }
    
}

struct OverlayContainerRepresentableAdaptor<Content: View, Background: View> {

    struct Context {
        let coordinator: OverlayContainerCoordinator
        let transaction: Transaction
    }

    let containerState: OverlayContainerState
    let passiveContainer: OverlayContainerPassiveContainer
    let content: Content
    let background: Background

    let model: DynamicOverlayContainerModel?
    
    
    
//    private let style: OverlayContainerViewController.OverlayStyle = .flexibleHeight
    private let style: OverlayContainerViewController.OverlayStyle = .rigid
//    private let style: OverlayContainerViewController.OverlayStyle = .expandableHeight

    // MARK: - UIViewControllerRepresentable

    func makeCoordinator() -> OverlayContainerCoordinator {
        debugPrint("[OVERLAY] OverlayContainerRepresentableAdaptor -- makeCoordinator")

        let contentController = UIHostingController(rootView: content)
        contentController.view.backgroundColor = .clear
//        contentController.view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//        contentController.view.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        
//        contentController.sizingOptions = .intrinsicContentSize
//        contentController.safeAreaRegions = []
        contentController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let backgroundController = UIHostingController(rootView: background)
        
//        backgroundController.safeAreaRegions = []
//        backgroundController.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        backgroundController.view.backgroundColor = .clear
        return OverlayContainerCoordinator(
            style: style,
            layout: containerState.layout,
            passiveContainer: passiveContainer,
            background: backgroundController,
            content: contentController,
            model: model
        )
    }

    func makeUIViewController(context: Context) -> CustomOverlayContainerViewController {
        debugPrint("[OVERLAY] OverlayContainerRepresentableAdaptor -- makeUIViewController")

        let controller = CustomOverlayContainerViewController(style: style)
        controller.delegate = context.coordinator
        
//        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        return controller
    }
    
    
    func updateUIViewController(_ container: CustomOverlayContainerViewController,
                                context: Context) {
        debugPrint("updateUIViewController", context.transaction)
        
        
        context.coordinator.move(
            container,
            to: containerState,
            animated: context.transaction.animation != nil
        )
    }
}



//
//struct OverlayContainerRepresentableAdaptor<Content: View, Background: View> {
//
//    struct Context {
//        let coordinator: OverlayContainerCoordinator
//        let transaction: Transaction
//    }
//
//    let containerState: OverlayContainerState
//    let passiveContainer: OverlayContainerPassiveContainer
//    let content: Content
//    let background: Background
//
//    private let style: OverlayContainerViewController.OverlayStyle = .expandableHeight
//
//    // MARK: - UIViewControllerRepresentable
//
//    func makeCoordinator() -> OverlayContainerCoordinator {
//        debugPrint("[OVERLAY] OverlayContainerRepresentableAdaptor -- makeCoordinator")
//
//        let contentController = UIHostingController(rootView: content)
//        contentController.view.backgroundColor = .clear
//        contentController.view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//        contentController.view.setContentHuggingPriority(.defaultLow, for: .vertical)
//        let backgroundController = UIHostingController(rootView: background)
//        backgroundController.view.backgroundColor = .clear
//        return OverlayContainerCoordinator(
//            style: style,
//            layout: containerState.layout,
//            passiveContainer: passiveContainer,
//            background: backgroundController,
//            content: contentController
//        )
//    }
//
//    func makeUIViewController(context: Context) -> OverlayContainerViewController {
//        debugPrint("[OVERLAY] OverlayContainerRepresentableAdaptor -- makeUIViewController")
//
//        let controller = OverlayContainerViewController(style: style)
//        controller.delegate = context.coordinator
//        return controller
//    }
//
//    func updateUIViewController(_ container: OverlayContainerViewController,
//                                context: Context) {
////        debugPrint("updateUIViewController", context)
//
//
//        context.coordinator.move(
//            container,
//            to: containerState,
//            animated: context.transaction.animation != nil
//        )
//    }
//}
