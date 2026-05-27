//
// VoltInputFieldStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 02/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

@MainActor
package protocol VoltInputFieldStyle: DynamicProperty {
    associatedtype Body: View

    typealias Configuration = VoltInputFieldStyleConfiguration

    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

extension VoltInputFieldStyle {
    func resolve(configuration: Configuration) -> some View {
        ResolvedVoltInputFieldStyle(configuration: configuration, style: self)
    }
}

struct ResolvedVoltInputFieldStyle<Style: VoltInputFieldStyle>: View {
    var configuration: Style.Configuration

    var style: Style

    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
