//
// Color+VoltColor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension Color {
    init(_ namespace: VoltColor.Namespace, _ name: VoltColor.Name) {
        self.init("\(namespace.rawValue)/\(name.rawValue.capitalized)", bundle: .module)
    }
}

extension Color {
    // Translucent Colors
    package static let voltTranslucentBlueColor = Color(.translucent, .blue)
    package static let voltTranslucentGreyColor = Color(.translucent, .grey)
    package static let voltTranslucentNavyColor = Color(.translucent, .navy)
    package static let voltTranslucentRedColor = Color(.translucent, .red)
    package static let voltTranslucentSteelColor = Color(.translucent, .steel)

    // Hint Colors
    package static let voltHintBlueColor = Color(.hint, .blue)
    package static let voltHintGreyColor = Color(.hint, .grey)
    package static let voltHintNavyColor = Color(.hint, .navy)
    package static let voltHintSteelColor = Color(.hint, .steel)

    // Soft Colors
    package static let voltSoftBlueColor = Color(.soft, .blue)
    package static let voltSoftGreyColor = Color(.soft, .grey)
    package static let voltSoftNavyColor = Color(.soft, .navy)
    package static let voltSoftSteelColor = Color(.soft, .steel)
    package static let voltSoftRedColor = Color(.soft, .red)
    package static let voltSoftOrangeColor = Color(.soft, .orange)
    package static let voltSoftGreenColor = Color(.soft, .green)

    // Light Colors
    package static let voltLightGreyColor = Color(.light, .grey)
    package static let voltLightNavyColor = Color(.light, .navy)
    package static let voltLightSteelColor = Color(.light, .steel)

    // Hazy Colors
    package static let voltHazyBlueColor = Color(.hazy, .blue)
    package static let voltHazyGreyColor = Color(.hazy, .grey)
    package static let voltHazyNavyColor = Color(.hazy, .navy)
    package static let voltHazySteelColor = Color(.hazy, .steel)
    package static let voltHazyRedColor = Color(.hazy, .red)
    package static let voltHazyOrangeColor = Color(.hazy, .orange)
    package static let voltHazyGreenColor = Color(.hazy, .green)

    // Faint Colors
    package static let voltFaintBlueColor = Color(.faint, .blue)
    package static let voltFaintGreyColor = Color(.faint, .grey)
    package static let voltFaintNavyColor = Color(.faint, .navy)
    package static let voltFaintSteelColor = Color(.faint, .steel)
    package static let voltFaintRedColor = Color(.faint, .red)
    package static let voltFaintOrangeColor = Color(.faint, .orange)
    package static let voltFaintGreenColor = Color(.faint, .green)

    // Muted Colors
    package static let voltMutedBlueColor = Color(.muted, .blue)
    package static let voltMutedGreyColor = Color(.muted, .grey)
    package static let voltMutedNavyColor = Color(.muted, .navy)
    package static let voltMutedSteelColor = Color(.muted, .steel)
    package static let voltMutedRedColor = Color(.muted, .red)
    package static let voltMutedOrangeColor = Color(.muted, .orange)
    package static let voltMutedGreenColor = Color(.muted, .green)

    // Balanced Colors
    package static let voltBalancedBlueColor = Color(.balanced, .blue)
    package static let voltBalancedGreyColor = Color(.balanced, .grey)
    package static let voltBalancedNavyColor = Color(.balanced, .navy)
    package static let voltBalancedSteelColor = Color(.balanced, .steel)
    package static let voltBalancedRedColor = Color(.balanced, .red)
    package static let voltBalancedOrangeColor = Color(.balanced, .orange)
    package static let voltBalancedGreenColor = Color(.balanced, .green)

    // Main Colors
    package static let voltMainBlueColor = Color(.main, .blue)
    package static let voltMainGreyColor = Color(.main, .grey)
    package static let voltMainNavyColor = Color(.main, .navy)
    package static let voltMainSteelColor = Color(.main, .steel)
    package static let voltMainRedColor = Color(.main, .red)
    package static let voltMainOrangeColor = Color(.main, .orange)
    package static let voltMainGreenColor = Color(.main, .green)

    // Rich Colors
    package static let voltRichBlueColor = Color(.rich, .blue)
    package static let voltRichGreyColor = Color(.rich, .grey)
    package static let voltRichNavyColor = Color(.rich, .navy)
    package static let voltRichSteelColor = Color(.rich, .steel)
    package static let voltRichRedColor = Color(.rich, .red)
    package static let voltRichOrangeColor = Color(.rich, .orange)
    package static let voltRichGreenColor = Color(.rich, .green)

    // Deep Colors
    package static let voltDeepBlueColor = Color(.deep, .blue)
    package static let voltDeepGreyColor = Color(.deep, .grey)
    package static let voltDeepNavyColor = Color(.deep, .navy)
    package static let voltDeepSteelColor = Color(.deep, .steel)
    package static let voltDeepRedColor = Color(.deep, .red)
    package static let voltDeepOrangeColor = Color(.deep, .orange)
    package static let voltDeepGreenColor = Color(.deep, .green)

    // Bold Colors
    package static let voltBoldBlueColor = Color(.bold, .blue)
    package static let voltBoldGreyColor = Color(.bold, .grey)
    package static let voltBoldNavyColor = Color(.bold, .navy)
    package static let voltBoldSteelColor = Color(.bold, .steel)
    package static let voltBoldRedColor = Color(.bold, .red)
    package static let voltBoldOrangeColor = Color(.bold, .orange)
    package static let voltBoldGreenColor = Color(.bold, .green)

    // Dark Colors
    package static let voltDarkBlueColor = Color(.dark, .blue)
    package static let voltDarkGreyColor = Color(.dark, .grey)
    package static let voltDarkNavyColor = Color(.dark, .navy)
    package static let voltDarkSteelColor = Color(.dark, .steel)
    package static let voltDarkRedColor = Color(.dark, .red)
    package static let voltDarkOrangeColor = Color(.dark, .orange)
    package static let voltDarkGreenColor = Color(.dark, .green)

    // Status Colors
    package static let voltStatusFailureColor = Color(.status, .failure)
    package static let voltStatusProcessingColor = Color(.status, .processing)
    package static let voltStatusSuccessColor = Color(.status, .success)
}
