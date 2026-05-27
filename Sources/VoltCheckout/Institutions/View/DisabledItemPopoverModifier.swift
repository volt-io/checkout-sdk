//
// DisabledItemPopoverModifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 27/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI
import VoltDesignSystem

struct DisabledItemPopoverModifier: ViewModifier {
    @Binding var item: Institution.Item?
    @State private var isPresented = false
    @State private var name = ""

    func body(content: Content) -> some View {
        content
            .voltPopoverToast(
                isPresented: $isPresented,
                title: "\(name) isn't available right now",
                message: "Please pick another bank"
            )
            .onChange(of: item) { newValue in
                if let newValue {
                    name = newValue.branchName ?? newValue.name
                }
                withAnimation {
                    isPresented = newValue != nil
                }
            }
            .onChange(of: isPresented) { newValue in
                if !newValue {
                    item = nil
                }
            }
    }
}

extension View {
    func disabledItemPopover(_ item: Binding<Institution.Item?>) -> some View {
        modifier(DisabledItemPopoverModifier(item: item))
    }
}
