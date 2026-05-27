//
// VoltOptionPicker.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 19/11/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltOptionPicker: View {
    let title: String
    let options: [String]
    @Binding var selected: String?

    package var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ForEach(options, id: \.self) { option in
                Divider()
                Toggle(isOn: isOn(option)) {
                    Text(option)
                        .font(.voltSubheadline)
                }
                .padding(.vertical, .voltPadding4)
                .toggleStyle(.voltRadio)
                .tag(option)
            }
        }
        .accessibilityRepresentation {
            Picker(title, selection: $selected) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                        .tag(option)
                }
            }
        }
    }

    private func isOn(_ option: String) -> Binding<Bool> {
        Binding {
            option == selected
        } set: { isOn in
            selected = isOn ? option : nil
        }
    }
}

extension VoltOptionPicker {
    package init(_ title: String, options: [String], selected: Binding<String?>) {
        self.title = title
        self.options = options
        self._selected = selected
    }
}
