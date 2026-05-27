//
// UIView+Subviews.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 31/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import UIKit

extension UIView {
    func firstSubview<T: UIView>(ofType type: T.Type) -> T? {
        for subview in subviews {
            if let match = subview as? T {
                return match
            }
        }
        for subview in subviews {
            if let foundInChild = subview.firstSubview(ofType: type) {
                return foundInChild
            }
        }
        return nil
    }

    func firstSubview<T: UIView>() -> T? {
        firstSubview(ofType: T.self)
    }

    func lastSubview<T: UIView>(ofType type: T.Type) -> T? {
        for subview in subviews.reversed() {
            if let match = subview as? T {
                return match
            }
        }
        for subview in subviews {
            if let foundInChild = subview.lastSubview(ofType: type) {
                return foundInChild
            }
        }
        return nil
    }

    func lastSubview<T: UIView>() -> T? {
        lastSubview(ofType: T.self)
    }
}
