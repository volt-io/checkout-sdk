//
// UIColor+VoltColor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 24/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension ColorResource {
    init(_ namespace: VoltColor.Namespace, _ name: VoltColor.Name) {
        self.init(name: "\(namespace.rawValue)/\(name.rawValue.capitalized)", bundle: .module)
    }
}

extension UIColor {
    package static let voltMainSteelColor = UIColor(resource: ColorResource(.main, .steel))
    package static let voltMainBlueColor = UIColor(resource: ColorResource(.main, .blue))
    package static let voltTranslucentNavyColor = UIColor(resource: ColorResource(.translucent, .navy))
    package static let voltLightNavyColor = UIColor(resource: ColorResource(.light, .navy))
    package static let voltFaintSteelColor = UIColor(resource: ColorResource(.faint, .steel))
}
