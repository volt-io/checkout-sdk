//
// VoltDefaultInputFieldStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 02/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import SwiftUIValidation

@MainActor
package struct VoltDefaultInputFieldStyle: VoltInputFieldStyle {
    @Environment(\.inputValidationResult) var validationResult
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.isFocused) var shouldFocus
    @FocusState var isFocused: Bool

    @ScaledMetric private var labelPadding: CGFloat = .voltPadding2
    @ScaledMetric private var inputPadding: CGFloat = .voltPadding3
    @ScaledMetric private var inputContentHeight: CGFloat = 24.0
    @ScaledMetric private var inputBorderRadius: CGFloat = .voltRadius1
    @ScaledMetric private var textFieldHeight: CGFloat = VoltFont.size(for: .subheadline)
    @ScaledMetric private var textFieldBaselineFix: CGFloat = 1.0
    @ScaledMetric private var textFieldStrokeWidth: CGFloat = 1.0

    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: inputBorderRadius)
            .fill(isEnabled ? Color.voltTranslucentNavyColor : .voltSoftNavyColor)
    }

    private var inputBorder: some View {
        RoundedRectangle(cornerRadius: inputBorderRadius)
            .stroke(!validationResult.isValid ? Color.voltMainRedColor :
                        isFocused ? .voltMainBlueColor :
                        isEnabled ? .voltLightNavyColor : .voltSoftNavyColor,
                    lineWidth: textFieldStrokeWidth)
    }

    package func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: labelPadding) {
            makeLabel(configuration: configuration)

            HStack(alignment: .center, spacing: inputPadding) {
                if let icon = configuration.icon {
                    makeIcon(icon: icon)
                }
                makeTextField(configuration: configuration)
                if !configuration.value.isEmpty {
                    makeClearButton(configuration: configuration)
                }
            }
            .onChange(of: shouldFocus) { isFocused = $0 }
            .onAppear { isFocused = shouldFocus }
            .padding(inputPadding)
            .background(inputBackground)
            .overlay(inputBorder)

            makeHelpLabel(configuration: configuration)
        }
        .padding(.horizontal, textFieldStrokeWidth)
        .focused($isFocused)
    }

    // MARK: - Helpers

    private func makeLabel(configuration: Configuration) -> some View {
        configuration.label
            .font(.voltCaption)
            .foregroundStyle(isEnabled ? Color.voltMainSteelColor : .voltFaintSteelColor)
            .padding(labelPadding)
            .onTapGesture { isFocused = true }
    }

    private func makeHelpLabel(configuration: Configuration) -> some View {
        Group {
            if case .invalid(let reason) = validationResult, let reason {
                Text(reason)
                    .foregroundStyle(Color.voltMainRedColor)
            } else {
                configuration.help
                    .foregroundStyle(Color.voltMutedSteelColor)
            }
        }
        .font(.voltCaption)
        .lineSpacing(VoltFont.lineSpacing(for: .caption))
        .padding(labelPadding)
    }

    private func makeIcon(icon: some View) -> some View {
        icon
            .frame(width: inputContentHeight, height: inputContentHeight)
            .opacity(isEnabled ? 1.0 : 0.3)
            .onTapGesture { isFocused = true }
    }

    private func makeTextField(configuration: Configuration) -> some View {
        TextField(text: configuration.$value) {
            makePrompt(configuration: configuration)
                .foregroundStyle(Color.voltFaintSteelColor)
                .font(.voltSubheadline)
        }
        .textFieldStyle(.plain)
        .autocorrectionDisabled()
        .padding(.top, textFieldBaselineFix)
        .frame(height: inputContentHeight)
        .foregroundStyle(isEnabled ? Color.voltMainSteelColor : .voltFaintSteelColor)
        .font(.voltSubheadline)
    }

    private func makePrompt(configuration: Configuration) -> some View {
        if let prompt = configuration.prompt {
            Configuration.Wrapper(prompt)
        } else {
            configuration.label
        }
    }

    private func makeClearButton(configuration: Configuration) -> some View {
        Button {
            configuration.value = ""
        } label: {
            Image.voltClearIcon
                .resizable()
                .renderingMode(.original)
                .frame(width: inputContentHeight, height: inputContentHeight)
                .aspectRatio(1.0, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}

extension VoltInputFieldStyle where Self == VoltDefaultInputFieldStyle {
    package static var `default`: Self { .init() }
}
