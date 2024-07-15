//
//  DynamicOverlayScrollViewProxyPreferenceKey.swift
//  DynamicOverlay
//
//  Created by Gaétan Zanella on 11/01/2022.
//  Copyright © 2022 Fabernovel. All rights reserved.
//

import SwiftUI

struct DynamicOverlayScrollViewProxy: Equatable {

    private let area: ActivatedOverlayArea

    init(area: ActivatedOverlayArea) {
        self.area = area
    }

    static var `default`: DynamicOverlayScrollViewProxy {
        DynamicOverlayScrollViewProxy(area: .default)
    }

    func findScrollView(in space: UIView) -> UIScrollView? {
        space.findScrollView(in: area, coordinate: space)
    }
}


struct DynamicOverlayScrollViewProxyPreferenceKey: PreferenceKey {

    typealias Value = ActivatedOverlayArea

    static var defaultValue: ActivatedOverlayArea = .default

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue())
    }
}

struct SymDynamicOverlayScrollViewProxyPreferenceKey: PreferenceKey {

    typealias Value = [String: ActivatedOverlayArea]
    
    static var defaultValue: [String: ActivatedOverlayArea] = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
    
}

private extension UIView {

    func findScrollView(in area: ActivatedOverlayArea,
                        coordinate: UICoordinateSpace) -> UIScrollView? {
        let frame = coordinate.convert(bounds, from: self)
        guard area.intersects(frame) else { return nil }
        if let result = self as? UIScrollView {
//            return result
            
            if result.contentSize.width > result.frame.width {
                debugPrint("HScroll -- skipping")
                
            } else {
                return result
            }
        }
        
        for subview in subviews {
            if let result = subview.findScrollView(in: area, coordinate: coordinate) {
                return result
            }
        }
        return nil
    }
}
