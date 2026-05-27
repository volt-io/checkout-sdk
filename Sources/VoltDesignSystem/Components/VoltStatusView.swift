//
// VoltStatusView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 13/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltStatusView<Icon: View, Header: View, Description: View>: View {
    package let state: VoltStatusProgressState
    package let icon: Icon
    package let header: Header
    package let description: Description

    private let initialProgressValue = 0.15
    private let initialRotationAngle: Angle = .zero
    private let initialScaleModifier: CGFloat = 1.0

    @ScaledMetric private var progressRadius: CGFloat = 56.0
    @State private var progressValue: Double
    @State private var rotationAngle: Angle
    @State private var scaleModifier: CGFloat

    package init(
        state: VoltStatusProgressState,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder header: () -> Header,
        @ViewBuilder description: () -> Description
    ) {
        self.state = state
        self.icon = icon()
        self.header = header()
        self.description = description()
        self.progressValue = initialProgressValue
        self.rotationAngle = initialRotationAngle
        self.scaleModifier = initialScaleModifier
    }

    package var body: some View {
        VStack(alignment: .center, spacing: 0.0) {
            progress
                .padding(.voltPadding5)
            header
                .font(.voltTitle2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.voltMainSteelColor)
                .padding(.vertical, .voltPadding3)
            VStack(spacing: 0.0) {
                description
                    .font(.voltFootnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.voltMutedSteelColor)
                    .lineLimit(2, reservesSpace: true)
                    .lineSpacing(VoltFont.lineSpacing(for: .footnote))
            }
            .frame(height: VoltFont.size(for: .footnote) * 2 + VoltFont.lineSpacing(for: .footnote))
            .padding(.vertical, .voltPadding3)
        }
        .onAppear {
            animate(for: state)
        }
        .onChange(of: state) { newState in
            animate(for: newState)
        }
    }

    var progress: some View {
        ZStack {
            ProgressView(value: progressValue)
                .progressViewStyle(.voltCircular)
                .frame(width: progressRadius * 2.0, height: progressRadius * 2.0)
                .rotationEffect(rotationAngle)
                .tint(state.tint)
            Group {
                if case .processing = state {
                    icon
                } else {
                    ProgressStateIndicator(state: state, scale: progressRadius)
                        .foregroundStyle(indicatorForeground)
                        .contentTransition(.opacity)
                }
            }
            .frame(maxWidth: progressRadius, maxHeight: progressRadius)
            .drawingGroup()
        }
        .scaleEffect(scaleModifier)
    }

    private var indicatorForeground: some ShapeStyle {
        if case .pending = state {
            LinearGradient(
                colors: [state.tint.opacity(0.2), state.tint],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            LinearGradient(colors: [state.tint], startPoint: .leading, endPoint: .trailing)
        }
    }

    private func animate(for state: VoltStatusProgressState) {
        if case .processing = state {
            progressValue = initialProgressValue
            scaleModifier = initialScaleModifier

            withAnimation(.linear(duration: 0.6).repeatForever(autoreverses: false)) {
                rotationAngle = .degrees(360)
            }
            withAnimation(.easeOut(duration: 1.3).repeatForever()) {
                progressValue = 1.0 - initialProgressValue
            }
        } else {
            withAnimation(.easeInOut(duration: 0.6)) {
                progressValue = 1.0
            }
        }
    }
}

package enum VoltStatusProgressState: CGFloat, CaseIterable {
    case processing, pending, success, failure

    package init(rawValue: CGFloat) {
        switch rawValue {
        case 0.0:
            self = .failure
        case 0.5:
            self = .pending
        case 1.0:
            self = .success
        default:
            self = .processing
        }
    }

    var tint: Color {
        switch self {
        case .failure:
            .voltStatusFailureColor
        case .success:
            .voltStatusSuccessColor
        case .processing, .pending:
            .voltStatusProcessingColor
        }
    }
}

extension VoltStatusView {
    struct ProgressStateIndicator: Shape {
        var state: VoltStatusProgressState
        var scale: CGFloat

        var animatableData: AnimatablePair<VoltStatusProgressState.RawValue, CGFloat> {
            get { .init(state.rawValue, scale) }
            set {
                state = .init(rawValue: newValue.first)
                scale = newValue.second
            }
        }

        @ScaledMetric private var strokeWidth: CGFloat = .voltStroke3

        func path(in _: CGRect) -> Path {
            Path { path in
                switch state {
                case .processing:
                    path.closeSubpath()
                case .pending:
                    path.move(to: .init(x: 0.05, y: 0.32))
                    path.addLine(to: .init(x: 0.21, y: 0.5))
                    path.addLine(to: .init(x: 0.05, y: 0.68))
                    path.move(to: .init(x: 0.42, y: 0.32))
                    path.addLine(to: .init(x: 0.58, y: 0.5))
                    path.addLine(to: .init(x: 0.42, y: 0.68))
                    path.move(to: .init(x: 0.79, y: 0.32))
                    path.addLine(to: .init(x: 0.95, y: 0.5))
                    path.addLine(to: .init(x: 0.79, y: 0.68))
                case .success:
                    path.move(to: .init(x: 0.04, y: 0.60))
                    path.addLine(to: .init(x: 0.29, y: 0.85))
                    path.addLine(to: .init(x: 0.96, y: 0.19))
                case .failure:
                    path.move(to: .init(x: 0.18, y: 0.18))
                    path.addLine(to: .init(x: 0.82, y: 0.82))
                    path.move(to: .init(x: 0.18, y: 0.82))
                    path.addLine(to: .init(x: 0.82, y: 0.18))
                }
            }
            .applying(.init(scaleX: scale, y: scale))
            .strokedPath(.init(lineWidth: strokeWidth, lineCap: .round))
        }
    }
}
