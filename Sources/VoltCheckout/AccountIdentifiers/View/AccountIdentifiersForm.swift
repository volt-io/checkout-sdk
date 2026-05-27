//
// AccountIdentifiersForm.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import SwiftUIValidation
import VoltDesignSystem

struct AccountIdentifiersForm: View {
    @Perception.Bindable var store: StoreOf<AccountIdentifiersFeature>
    @Environment(\.formValidationResult) private var validationResult
    @FocusState private var focusedField: AccountIdentifier?
    @State private var submitLabel: SubmitLabel = .next

    var body: some View {
        GeometryReader { proxy in
            WithPerceptionTracking {
                ScrollView {
                    WithPerceptionTracking {
                        VStack(spacing: .voltPadding5) {
                            Text("Additional details are required by your bank to complete this payment.")
                                .voltSubtitleTextStyle()

                            IBANInputField
                            numericInputFields(for: proxy.size.width)
                            PSUIdInputField

                            Button {
                                attemptSubmit()
                            } label: {
                                Text("Continue")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.voltPrimary)
                            .padding(.vertical, .voltPadding2)
                            .disabled(!validationResult.isValid)
                        }
                        .submitLabel(submitLabel)
                        .onSubmit {
                            attemptSubmit()
                        }
                    }
                    .padding(.voltPadding5)
                }
                .onSubmit {
                    updateSubmitLabel(for: validationResult)
                }
                .onChange(of: validationResult) { newResult in
                    updateSubmitLabel(for: newResult)
                }
                .onChange(of: focusedField) { _ in
                    updateSubmitLabel(for: validationResult)
                }
                .onAppear {
                    attemptSubmit()
                }
            }
        }
    }

    @ViewBuilder private var IBANInputField: some View {
        if store.data.IBAN != nil {
            VoltInputField(
                "IBAN",
                value: $store.data.IBAN,
                format: .iban,
                prompt: Text(store.institution.country.locale.identifier.uppercased()),
                help: Text(IBAN.helpMessage),
                icon: { institutionLogo }
            )
            .focused($focusedField, equals: .IBAN)
            .textInputAutocapitalization(.characters)
            .validationStyle(.iban, for: store.data.IBAN?.rawValue)
        }
    }

    @ViewBuilder private var branchCodeInputField: some View {
        if store.data.branchCode != nil {
            VoltInputField(
                "Branch code",
                value: $store.data.branchCode,
                format: .branchCode,
                prompt: Text(BranchCode.prompt),
                help: Text(BranchCode.helpMessage)
            )
            .focused($focusedField, equals: .branchCode)
            .keyboardType(.numberPad)
            .validationStyle(.branchCode, for: store.data.branchCode?.rawValue)
        }
    }

    @ViewBuilder private var accountNumberInputField: some View {
        if store.data.accountNumber != nil {
            VoltInputField(
                "Account number",
                value: $store.data.accountNumber,
                format: .accountNumber(store.country.locale),
                prompt: Text(AccountNumber.prompt(for: store.country.locale)),
                help: Text(AccountNumber.helpMessage(for: store.country.locale))
            )
            .focused($focusedField, equals: .accountNumber)
            .keyboardType(.numberPad)
            .validationStyle(.accountNumber(store.country.locale), for: store.data.accountNumber?.number)
        }
    }

    @ViewBuilder private var PSUIdInputField: some View {
        if store.data.PSUId != nil {
            VoltInputField(
                psuIdLabelKey,
                value: $store.data.PSUId,
                format: .psuId,
                help: Text(PSUId.helpMessage)
            )
            .focused($focusedField, equals: .PSUId)
            .textInputAutocapitalization(.never)
            .validationStyle(.psuId, for: store.data.PSUId?.rawValue)
        }
    }

    @ViewBuilder private func numericInputFields(for width: CGFloat) -> some View {
        if store.data.branchCode != nil, store.data.accountNumber != nil {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: .voltPadding7) {
                    branchCodeInputField
                        .frame(minWidth: width * 0.2)
                    accountNumberInputField
                        .frame(minWidth: width * 0.6)
                }
                VStack {
                    branchCodeInputField
                    accountNumberInputField
                }
            }
        } else {
            branchCodeInputField
            accountNumberInputField
        }
    }

    private var institutionLogo: some View {
        AsyncSVGImage(url: store.institution.logo) {
            ProgressView()
        } failed: {
            Image.voltBankIcon
        }
    }

    private var psuIdLabelKey: LocalizedStringKey {
        if store.country.locale == .sweden || store.country.locale == .norway {
            "Social security number"
        } else {
            "\(store.institution.name) ID"
        }
    }

    private var nextFocusedField: AccountIdentifier? {
        let requiredIdentifiers = store.data.requiredIdentifiers

        if let focusedField, let currentIndex = requiredIdentifiers.firstIndex(of: focusedField) {
            let nextIndex = requiredIdentifiers.index(after: currentIndex)

            if nextIndex < requiredIdentifiers.endIndex {
                return requiredIdentifiers[nextIndex]
            }
        }

        return requiredIdentifiers.first
    }

    private func updateSubmitLabel(for validationResult: ValidationResult) {
        submitLabel = validationResult.isValid ? .return : .next
    }

    private func attemptSubmit() {
        if validationResult.isValid {
            store.send(.view(.onContinueButtonTapped))
        } else {
            focusedField = nextFocusedField
        }
    }
}
