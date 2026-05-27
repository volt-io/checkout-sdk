//
// PaymentFlowPreview.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 22/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// swiftlint:disable closure_body_length
#Preview {
    struct AppCheckout: View {
        let voltCheckout: VoltCheckout
        let currency = Currency.EUR
        let defaultCountry = Country(.germany)
        let sparkasse = Institution(
            id: "643df330-d162-4202-a732-784f64ee85c1",
            name: "Berliner Sparkasse",
            logo: URL(string: "https://cdn.volt.io/chk3_banks/logos/xx_sparkasse.svg"),
            country: Country(.germany)
        )

        @State var flowResult: CheckoutResult?

        var body: some View {
            NavigationStack {
                List {
                    products
                    summary
                    paymentMethods
                    debug
                }
                .searchable(text: .constant(""))
                .navigationTitle("App Checkout")
            }
            .voltCheckoutSheet(using: voltCheckout)
        }

        var products: some View {
            Section("Products") {
                HStack {
                    Label("T-shirt", systemImage: "tshirt")
                    Spacer()
                    Text(9.formatted(.currency(code: currency.rawValue)))
                }
                HStack {
                    Label("Shoes", systemImage: "shoe.2")
                    Spacer()
                    Text(29.formatted(.currency(code: currency.rawValue)))
                }
                HStack {
                    Label("Handbag", systemImage: "handbag")
                    Spacer()
                    Text(39.formatted(.currency(code: currency.rawValue)))
                }
            }
        }

        var summary: some View {
            Section("Summary") {
                HStack {
                    Label("Total", systemImage: "basket")
                    Spacer()
                    Text(77.formatted(.currency(code: currency.rawValue)))
                }
            }
        }

        var paymentMethods: some View {
            Section("Payment methods") {
                Button {
                    Task {
                        await payByBank(total: 77)
                    }
                } label: {
                    Label("Pay by bank...", systemImage: "building.columns")
                }
                Button {
                    Task {
                        await payByBank(total: 77, institution: sparkasse)
                    }
                } label: {
                    Label("Paying with \(sparkasse.name)", systemImage: "s.circle")
                }
            }
        }

        var debug: some View {
            Section("Flow result value") {
                ScrollView(.horizontal) {
                    Text(String(customDumping: flowResult))
                        .font(.caption2)
                        .monospaced()
                }
                Button {
                    flowResult = nil
                } label: {
                    Text("Clear result")
                }
            }
        }

        // swiftlint:disable force_unwrapping
        func payByBank(total: UInt, institution: Institution? = nil) async {
            let amount = Amount(currency: currency, minorUnits: total)!
            let payerRef = Payer.Reference("johndoe@example.com")!
            let person = Payer.Person(firstName: "John", lastName: "Doe")!

            let intent = PaymentIntent(
                amount: amount,
                payer: Payer(reference: payerRef, entity: .person(person)),
                transactionType: .goods
            )

            if let institution {
                flowResult = await voltCheckout.payment(with: intent, hints: .useInstitution(institution))
            } else {
                flowResult = await voltCheckout.payment(with: intent, hints: .useDefaultCountry(defaultCountry))
            }
        }
        // swiftlint:enable force_unwrapping
    }

    let checkout = VoltCheckout(configuration: .sandbox(customerId: "", tokenProvider: { "" }))
    return AppCheckout(voltCheckout: checkout)
}
// swiftlint:enable closure_body_length
