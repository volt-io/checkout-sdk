//
// VoltCheckout+AgreementClause.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 03/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

public import Foundation
import VoltDesignSystem

extension VoltCheckout {
    /// Provides attributed text value for the agreement clause that has to be displayed to user before payment.
    public struct AgreementClause {
        /// Agreement clause text.
        ///
        /// This clause needs to be visible to the shopper before initializing the payment
        ///
        /// Example usage:
        /// ```
        /// // SwiftUI
        /// Text(VoltCheckout.agreementClause)
        ///     .foregroundColor(.primary)
        ///     .tint(.accentColor)
        /// ```
        /// ```
        /// // UIKit
        /// let label = UILabel()
        /// label.attributedText = NSAttributedString(VoltSDK.agreementClause)
        /// ```
        public static var attributedText: AttributedString {
            var string = AttributedString(localized:
                """
                By continuing you agree to the [Terms and Conditions](https://checkout.volt.io/legal-providers) and
                [Privacy Policies](https://checkout.volt.io/legal-providers) of Volt and indicated connectivity provider.
                """
            )

            guard let termsRange = string.range(of: "Terms and Conditions"),
                  let policiesRange = string.range(of: "Privacy Policies") else {
                return string
            }

            string.font = .voltCaption
            string[termsRange].font = .voltCaption.weight(.medium)
            string[policiesRange].font = .voltCaption.weight(.medium)

            return string
        }
    }
}
