//
// InstitutionsPreview.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 29/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

// swiftlint:disable closure_body_length
#Preview {
    struct AppTopUp: View {
        let voltCheckout: VoltCheckout
        let currency = Currency.EUR
        let defaultCountry = Country(.germany)

        @State var flowResult: CheckoutResult?
        @State var institution: Institution?
        @State var amount = 1.0

        var body: some View {
            NavigationStack {
                List {
                    Section("Fund your account") {
                        TextField("Amount", value: $amount, format: .currency(code: currency.locale.identifier))
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    Section("Select your bank") {
                        if let institution {
                            HStack {
                                Label {
                                    Text("Paying with \(institution.name)")
                                } icon: {
                                    AsyncSVGImage(url: institution.logo) {
                                        ProgressView()
                                    } failed: {
                                        Image(systemName: "building.columns")
                                            .accessibilityHidden(true)
                                    }
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .cornerRadius(.voltRadius1)
                                }
                                Spacer()
                                changeBankButton
                                clearBankButton
                            }
                        } else {
                            selectBankButton
                        }
                    }
                    Section {
                        VStack(alignment: .center) {
                            ZStack {
                                Text(VoltCheckout.AgreementClause.attributedText)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                fixThis
                            }
                            .padding(.top)
                            transferButton
                                .padding(.bottom)
                        }
                    }
                    Section("Flow result value") {
                        ScrollView(.horizontal) {
                            Text(String(customDumping: flowResult))
                                .font(.caption2)
                                .monospaced()
                        }
                    }
                }
                .searchable(text: .constant(""))
                .navigationTitle("App TopUp")
            }
            .voltCheckoutSheet(using: voltCheckout)
        }

        var changeBankButton: some View {
            Button {
                Task {
                    await selectBank()
                }
            } label: {
                Label("Change", systemImage: "pencil")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
        }

        var clearBankButton: some View {
            Button {
                institution = nil
            } label: {
                Label("Clear", systemImage: "xmark")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
        }

        var selectBankButton: some View {
            Button {
                Task {
                    await selectBank()
                }
            } label: {
                Label("Select your bank...", systemImage: "building.columns")
            }
        }

        var fixThis: some View {
            Text("FIX THIS")
                .foregroundStyle(.red)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .kerning(10)
                .opacity(0.75)
                .rotationEffect(.degrees(-7))
        }

        var transferButton: some View {
            Button {
                Task {
                    await transferFunds()
                }
            } label: {
                Text("Transfer funds")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }

        func selectBank() async {
            flowResult = await voltCheckout.institution(
                for: currency,
                hints: .useDefaultCountry(defaultCountry)
            )
            if case let .institutionSelected(institution: selected) = flowResult {
                institution = selected
            }
        }

        // swiftlint:disable force_unwrapping
        func transferFunds() async {
            let amount = Amount(currency: currency, minorUnits: UInt(amount * 100))!
            let payerRef = Payer.Reference("johndoe@example.com")!
            let person = Payer.Person(firstName: "John", lastName: "Doe")!

            let intent = PaymentIntent(
                amount: amount,
                payer: Payer(reference: payerRef, entity: .person(person)),
                transactionType: .goods
            )

            if let institution {
                await voltCheckout.payment(with: intent, hints: .useInstitution(institution))
            } else {
                flowResult = await voltCheckout.payment(with: intent, hints: .useDefaultCountry(defaultCountry))
                if case let .paymentCreated(_, _, institution: completed) = flowResult {
                    institution = completed
                }
            }
        }
        // swiftlint:enable force_unwrapping
    }

    let checkout = VoltCheckout(configuration: .sandbox(customerId: "", tokenProvider: { "" }))
    return AppTopUp(voltCheckout: checkout)
}
// swiftlint:enable closure_body_length
