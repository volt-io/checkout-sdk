//
// VoltInputFieldStyleConfiguration.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 02/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltInputFieldStyleConfiguration {
    @Binding var value: String

    let label: Wrapper
    let icon: Wrapper?
    let prompt: Text?
    let help: Text?

    @MainActor init<Label: View, Icon: View>(
        value: Binding<String>,
        label: Label,
        icon: Icon? = nil,
        prompt: Text? = nil,
        help: Text? = nil
    ) {
        self._value = value
        self.label = label as? Self.Wrapper ?? .init(label)
        self.icon = icon as? Self.Wrapper ?? .init(icon)
        self.prompt = prompt
        self.help = help
    }
}

extension VoltInputFieldStyleConfiguration {
    struct Wrapper: View {
        let underlyingView: AnyView

        init(_ view: some View) {
            self.underlyingView = AnyView(view)
        }

        var body: some View {
            underlyingView
        }
    }
}
