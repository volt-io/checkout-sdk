//
// View+VoltCheckout.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

public import SwiftUI

extension View {
    /// Shows Volt Checkout flow as a full screen cover over a view that it's attached to.
    ///
    /// Use this modifier when integrating with your SwiftUI app. Attach it to the view on top of which
    /// you want the payment process to begin. Use `VoltCheckout` public methods to begin specific flow.
    /// From there checkout sheet controls it's presentation, and will dismiss after completing the flow.
    /// - Parameters:
    ///   - checkout: Pass your configured instance of the `VoltCheckout` SDK class.
    /// - Returns: Modified view.
    public func voltCheckoutSheet(using checkout: VoltCheckout) -> some View {
        modifier(CheckoutSheetModifier(store: checkout.store))
    }
}
