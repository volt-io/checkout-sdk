//
// VoltInputFieldStyleKey.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 02/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

// TODO: change @preconcurrency to @MainActor after updating gitlab runner to Xcode 26
struct VoltInputFieldStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: any VoltInputFieldStyle = VoltDefaultInputFieldStyle()
}

extension EnvironmentValues {
    @MainActor var voltInputFieldStyle: any VoltInputFieldStyle {
        get { self[VoltInputFieldStyleKey.self] }
        set { self[VoltInputFieldStyleKey.self] = newValue }
    }
}

extension View {
    package func voltInputFieldStyle(_ style: some VoltInputFieldStyle) -> some View {
        environment(\.voltInputFieldStyle, style)
    }
}
