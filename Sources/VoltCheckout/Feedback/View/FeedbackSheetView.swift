//
// FeedbackSheetView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 27/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import VoltDesignSystem

struct FeedbackSheetView: View {
    @Perception.Bindable var store: StoreOf<FeedbackFeature>
    @Environment(\.dismiss) var dismiss

    @State private var contentHeight: CGFloat = 0.0
    @State private var isVerticalSizeFixed = true

    var body: some View {
        GeometryReader { containerProxy in
            WithPerceptionTracking {
                VStack {
                    title
                    headline
                    feedbackForm
                    submitButton
                }
                .padding(.horizontal, .voltPadding6)
                .fixedSize(horizontal: false, vertical: isVerticalSizeFixed)
                .onGeometryChange(for: CGFloat.self, of: { proxy in
                    proxy.size.height
                }, action: { newHeight in
                    contentHeight = newHeight
                    isVerticalSizeFixed = contentHeight < containerProxy.size.height
                })
                .presentationDetents([.height(contentHeight)])
                .presentationCornerRadius(.voltRadius2)
                .presentationDragIndicator(.visible)
                .tint(.voltMainSteelColor)
                .onAppear {
                    store.send(.view(.onAppear))
                }
            }
        }
    }

    var title: some View {
        ZStack(alignment: .center) {
            Text("Cancel payment")
                .voltNavigationTitleStyle()
                .padding(.top, .voltPadding7)
            HStack {
                Spacer()
                VoltCloseButton {
                    dismiss()
                }
                .padding(.top, .voltPadding7)
            }
        }
    }

    var headline: some View {
        Text("To help us improve, please share why you want to cancel this checkout.")
            .voltHeadlineTextStyle()
            .padding(.top, .voltPadding4)
    }

    var feedbackForm: some View {
        VoltOptionPicker(
            "Select feedback option",
            options: store.options.map(\.rawValue),
            selected: $store.selectedOptionValue.sending(\.view.onSelectedFeedbackOption)
        )
        .padding(.top, .voltPadding5)
    }

    var submitButton: some View {
        Button {
            store.send(.view(.onSubmitButtonTapped))
        } label: {
            Text("Cancel Payment")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.voltPrimary)
        .padding(.bottom, .voltPadding7)
    }
}

extension View {
    func feedbackSheet(store: Binding<StoreOf<FeedbackFeature>?>) -> some View {
        self.sheet(item: store) { store in
            FeedbackSheetView(store: store)
        }
    }
}
