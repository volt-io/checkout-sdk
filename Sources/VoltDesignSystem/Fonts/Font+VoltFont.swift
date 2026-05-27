//
// Font+VoltDesignSystem.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension Font {
    package static func volt(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom(VoltFont.name(for: weight), size: size)
    }

    // swiftlint:disable cyclomatic_complexity
    package static func volt(_ style: Font.TextStyle, weight: Font.Weight? = nil) -> Font {
        switch style {
        case .largeTitle:
            Font.voltLargeTitle.weight(weight ?? .regular)
        case .title:
            Font.voltTitle.weight(weight ?? .regular)
        case .title2:
            Font.voltTitle2.weight(weight ?? .regular)
        case .title3:
            Font.voltTitle3.weight(weight ?? .regular)
        case .headline:
            Font.headline.weight(weight ?? .semibold)
        case .subheadline:
            Font.voltSubheadline.weight(weight ?? .regular)
        case .body:
            Font.voltBody.weight(weight ?? .regular)
        case .callout:
            Font.voltCallout.weight(weight ?? .regular)
        case .footnote:
            Font.voltFootnote.weight(weight ?? .regular)
        case .caption:
            Font.voltCaption.weight(weight ?? .regular)
        case .caption2:
            Font.voltCaption2.weight(weight ?? .regular)
        default:
            Font.voltBody.weight(weight ?? .regular)
        }
    }
    // swiftlint:enable cyclomatic_complexity

    package static let voltLargeTitle = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .largeTitle), relativeTo: .largeTitle
    )

    package static let voltTitle = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .title), relativeTo: .title
    )

    package static let voltTitle2 = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .title2), relativeTo: .title2
    )

    package static let voltTitle3 = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .title3), relativeTo: .title3
    )

    package static let voltHeadline = Font.custom(
        VoltFont.name(for: .semibold), size: VoltFont.size(for: .headline), relativeTo: .headline
    )

    package static let voltSubheadline = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .subheadline), relativeTo: .subheadline
    )

    package static let voltBody = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .body), relativeTo: .body
    )

    package static let voltCallout = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .callout), relativeTo: .callout
    )

    package static let voltFootnote = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .footnote), relativeTo: .footnote
    )

    package static let voltCaption = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .caption), relativeTo: .caption
    )

    package static let voltCaption2 = Font.custom(
        VoltFont.name(for: .regular), size: VoltFont.size(for: .caption2), relativeTo: .caption2
    )
}
