//
//  EmptyFile.swift
//  DynamicOverlay
//
//  Created by Gaétan Zanella on 05/03/2019.
//  Copyright © 2019 Fabernovel. All rights reserved.
//

import SwiftUI


public struct OverlayTranslation {
    public let height: CGFloat
    public let transaction: Transaction
    public let isDragging: Bool
    public let translationProgress: CGFloat
    public let containerFrame: CGRect
    public let velocity: CGPoint
    public let heightForNotchIndex: (Int) -> CGFloat
}


public struct DynamicOverlayBehaviorValue {

    let notchDimensions: [Int: NotchDimension]?
    let block: ((OverlayTranslation) -> Void)?
    let binding: Binding<Int>?
    let disabledNotchIndexes: Set<Int>

    public init(notchDimensions: [Int: NotchDimension]? = nil,
         block: ((OverlayTranslation) -> Void)? = nil,
         binding: Binding<Int>? = nil,
         disabledNotchIndexes: Set<Int> = []) {
        self.notchDimensions = notchDimensions
        self.block = block
        self.binding = binding
        self.disabledNotchIndexes = disabledNotchIndexes
    }
}


public extension DynamicOverlayBehaviorValue {

    static var `default`: DynamicOverlayBehaviorValue {
        DynamicOverlayBehaviorValue(
            notchDimensions: [
                0 : .fractional(0.3),
                1 : .fractional(0.5),
                2 : .fractional(0.7)
            ]
        )
    }
}

struct DynamicOverlayBehaviorKey: EnvironmentKey {

    static var defaultValue: DynamicOverlayBehaviorValue = .default
}

extension EnvironmentValues {

    var behaviorValue: DynamicOverlayBehaviorValue {
        set {
            self[DynamicOverlayBehaviorKey.self] = newValue
        }
        get {
            self[DynamicOverlayBehaviorKey.self]
        }
    }
}
