//
// VoltFont.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package enum VoltFont {
    static let name = "Graphik"

    /// From heaviest to lightest. Importantly it doesn't translate one to one to `Font.Weight`.
    enum Variant: String, CaseIterable {
        /// `Font.Weight.black`
        case `super`, superItalic
        /// `Font.Weight.heavy`
        case black, blackItalic
        /// `Font.Weight.bold`
        case bold, boldItalic
        /// `Font.Weight.semibold`
        case semibold, semiboldItalic
        /// `Font.Weight.medium`
        case medium, mediumItalic
        /// `Font.Weight.regular`
        case regular, regularItalic
        /// `Font.Weight.light`
        case light, lightItalic
        /// `Font.Weight.thin`
        case extraLight, extraLightItalic
        /// `Font.Weight.ultralight`
        case thin, thinItalic

        var name: String {
            "\(VoltFont.name)-\(rawValue.prefix(1).capitalized)\(rawValue.dropFirst())"
        }
    }

    static func name(for weight: Font.Weight) -> String {
        switch weight {
        case .black:
            VoltFont.Variant.super.name
        case .heavy:
            VoltFont.Variant.black.name
        case .bold:
            VoltFont.Variant.bold.name
        case .semibold:
            VoltFont.Variant.semibold.name
        case .medium:
            VoltFont.Variant.medium.name
        case .regular:
            VoltFont.Variant.regular.name
        case .light:
            VoltFont.Variant.light.name
        case .thin:
            VoltFont.Variant.extraLight.name
        case .ultraLight:
            VoltFont.Variant.thin.name
        default:
            VoltFont.Variant.regular.name
        }
    }

    // swiftlint:disable cyclomatic_complexity
    static func size(for style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle:
            34.0
        case .title:
            28.0
        case .title2:
            22.0
        case .title3:
            20.0
        case .headline:
            17.0
        case .subheadline:
            15.0
        case .body:
            17.0
        case .callout:
            16.0
        case .footnote:
            13.0
        case .caption:
            12.0
        case .caption2:
            11.0
        default:
            17.0
        }
    }
    // swiftlint:enable cyclomatic_complexity

    package static func lineSpacing(for style: Font.TextStyle) -> CGFloat {
        size(for: style) * .voltLineSpacing
    }

    // swiftlint:disable force_cast
    package static func registerCustomFonts() {
        guard !(CTFontManagerCopyAvailableFontFamilyNames() as! [String]).contains(VoltFont.name) else { return }
        let fontURLs = VoltFont.Variant.allCases.compactMap {
            Bundle.module.url(forResource: $0.name, withExtension: "otf")
        }
        CTFontManagerRegisterFontURLs(fontURLs as CFArray, .process, true, nil)
    }
    // swiftlint:enable force_cast
}

extension View {
    package func loadCustomFonts() -> some View {
        VoltFont.registerCustomFonts()
        return self
    }
}
