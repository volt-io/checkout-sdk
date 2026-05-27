//
// VoltCircularProgressViewStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 13/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltCircularProgressViewStyle: ProgressViewStyle {
    @ScaledMetric private var strokeWidth: CGFloat = .voltStroke3

    package func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0.0

        return VStack {
            Circle()
                .trim(from: 0.0, to: fractionCompleted)
                .stroke(.tint, style: .init(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90.0))
        }
    }
}

extension ProgressViewStyle where Self == VoltCircularProgressViewStyle {
    package static var voltCircular: Self {
        VoltCircularProgressViewStyle()
    }
}
