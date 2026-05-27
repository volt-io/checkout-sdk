//
// EducationalView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/06/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

struct EducationalView: View {
    @Perception.Bindable var store: StoreOf<EducationalFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                GeometryReader { proxy in
                    ScrollView {
                        VStack(alignment: .center) {
                            Spacer()
                            title
                            Spacer()
                            proposition
                            Spacer()
                        }
                        .frame(minHeight: proxy.size.height)
                    }
                    .frame(width: proxy.size.width)
                    .scrollBounceBehavior(.basedOnSize)
                }
                VStack(spacing: .voltPadding5) {
                    Text(VoltCheckout.AgreementClause.attributedText)
                        .voltAgreementsClauseTextStyle()
                        .simultaneousGesture(TapGesture().onEnded { _ in
                            store.send(.onTermsAndConditionsTapped)
                        })
                        .accessibilityAddTraits(.isLink)
                    Button {
                        store.send(.onContinueButtonTapped)
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.voltPrimary)
                }
                .layoutPriority(1)
            }
            .padding(.horizontal, .voltPadding5)
            .padding(.bottom, .voltPadding8)
            .feedbackSheet(store: $store.scope(state: \.navBar.feedback, action: \.navBar._internal.feedback))
            .checkoutNavBar(store.scope(state: \.navBar, action: \.navBar))
            .onAppear {
                store.send(.onAppear)
            }
        }
    }

    var title: some View {
        GraphicTitleLabel {
            Image.voltShoppingCartIcon
        } rightIcon: {
            Image.voltLogoIcon.renderingMode(.original)
        } title: {
            Text("Pay instantly from your bank account")
        }
    }

    var proposition: some View {
        VStack(alignment: .leading, spacing: .voltPadding5) {
            ValuePropositionLabel(title: "Select your bank", subtitle: "From the list provided") {
                Image.voltShieldIcon
            }
            ValuePropositionLabel(title: "Log in to your bank", subtitle: "Securely, in seconds") {
                Image.voltFingerprintIcon
            }
            ValuePropositionLabel(title: "Approve your payment", subtitle: "A single tap is all it takes") {
                Image.voltCheckCircleIcon
            }
        }
    }
}
