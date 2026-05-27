//
// VoltInputField.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 18/02/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltInputField<Label, Icon>: View where Label: View, Icon: View {
    @Binding private var value: String
    @State private var formattedValue: String
    private let reformat: (() -> String)?

    private let label: Label
    private let icon: Icon?
    private let prompt: Text?
    private let help: Text?

    @Environment(\.voltInputFieldStyle) private var style

    private var formattedBinding: Binding<String> {
        Binding(
            get: { formattedValue },
            set: { value = $0 }
        )
    }

    package var body: some View {
        AnyView(style.resolve(configuration: .init(
            value: formattedBinding,
            label: label,
            icon: icon,
            prompt: prompt,
            help: help
        )))
        .onChange(of: value) { _ in
            guard let newFormattedValue = reformat?(), newFormattedValue != formattedValue else { return }
            formattedValue = newFormattedValue
        }
    }
}

extension VoltInputField where Label == Text, Icon == Image {
    package init(
        _ titleKey: LocalizedStringKey,
        value: Binding<String>,
        icon: Image? = nil,
        prompt: Text? = nil,
        help: Text? = nil
    ) {
        self._value = value
        self._formattedValue = State(initialValue: value.wrappedValue)
        self.reformat = nil
        self.label = Text(titleKey)
        self.icon = icon
        self.prompt = prompt
        self.help = help
    }

    package init<Format: ParseableFormatStyle>(
        _ titleKey: LocalizedStringKey,
        value: Binding<Format.FormatInput>,
        format: Format,
        icon: Image? = nil,
        prompt: Text? = nil,
        help: Text? = nil
    ) where Format.FormatOutput == String {
        self._value = Binding {
            format.format(value.wrappedValue)
        } set: {
            if let parsed = try? format.parseStrategy.parse($0) {
                value.wrappedValue = parsed
            }
        }
        self._formattedValue = State(initialValue: format.format(value.wrappedValue))
        self.reformat = { format.format(value.wrappedValue) }
        self.label = Text(titleKey)
        self.icon = icon
        self.prompt = prompt
        self.help = help
    }

    package init<Format: ParseableFormatStyle>(
        _ titleKey: LocalizedStringKey,
        value: Binding<Format.FormatInput?>,
        format: Format,
        icon: Image? = nil,
        prompt: Text? = nil,
        help: Text? = nil
    ) where Format.FormatOutput == String {
        self._value = Binding {
            value.wrappedValue.map { format.format($0) } ?? ""
        } set: {
            value.wrappedValue = try? format.parseStrategy.parse($0)
        }
        self._formattedValue = State(initialValue: value.wrappedValue.map { format.format($0) } ?? "")
        self.reformat = { value.wrappedValue.map { format.format($0) } ?? "" }
        self.label = Text(titleKey)
        self.icon = icon
        self.prompt = prompt
        self.help = help
    }
}

extension VoltInputField where Label == Text, Icon: View {
    package init(
        _ titleKey: LocalizedStringKey,
        value: Binding<String>,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder icon: () -> Icon
    ) {
        self._value = value
        self._formattedValue = State(initialValue: value.wrappedValue)
        self.reformat = nil
        self.label = Text(titleKey)
        self.icon = icon()
        self.prompt = prompt
        self.help = help
    }

    package init<Format: ParseableFormatStyle>(
        _ titleKey: LocalizedStringKey,
        value: Binding<Format.FormatInput>,
        format: Format,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder icon: () -> Icon
    ) where Format.FormatOutput == String {
        self._value = Binding {
            format.format(value.wrappedValue)
        } set: {
            if let parsed = try? format.parseStrategy.parse($0) {
                value.wrappedValue = parsed
            }
        }
        self._formattedValue = State(initialValue: format.format(value.wrappedValue))
        self.reformat = { format.format(value.wrappedValue) }
        self.label = Text(titleKey)
        self.icon = icon()
        self.prompt = prompt
        self.help = help
    }

    package init<Format: ParseableFormatStyle>(
        _ titleKey: LocalizedStringKey,
        value: Binding<Format.FormatInput?>,
        format: Format,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder icon: () -> Icon
    ) where Format.FormatOutput == String {
        self._value = Binding {
            value.wrappedValue.map { format.format($0) } ?? ""
        } set: {
            value.wrappedValue = try? format.parseStrategy.parse($0)
        }
        self._formattedValue = State(initialValue: value.wrappedValue.map { format.format($0) } ?? "")
        self.reformat = { value.wrappedValue.map { format.format($0) } ?? "" }
        self.label = Text(titleKey)
        self.icon = icon()
        self.prompt = prompt
        self.help = help
    }
}

extension VoltInputField where Label: View, Icon == Image {
    package init(
        value: Binding<String>,
        icon: Image? = nil,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self._value = value
        self._formattedValue = State(initialValue: value.wrappedValue)
        self.reformat = nil
        self.label = label()
        self.icon = icon
        self.prompt = prompt
        self.help = help
    }

    package init<Format: ParseableFormatStyle>(
        value: Binding<Format.FormatInput>,
        format: Format,
        icon: Image? = nil,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder label: () -> Label
    ) where Format.FormatOutput == String {
        self._value = Binding {
            format.format(value.wrappedValue)
        } set: {
            if let parsed = try? format.parseStrategy.parse($0) {
                value.wrappedValue = parsed
            }
        }
        self._formattedValue = State(initialValue: format.format(value.wrappedValue))
        self.reformat = { format.format(value.wrappedValue) }
        self.label = label()
        self.icon = icon
        self.prompt = prompt
        self.help = help
    }

    package init<Format: ParseableFormatStyle>(
        value: Binding<Format.FormatInput?>,
        format: Format,
        icon: Image? = nil,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder label: () -> Label
    ) where Format.FormatOutput == String {
        self._value = Binding {
            value.wrappedValue.map { format.format($0) } ?? ""
        } set: {
            value.wrappedValue = try? format.parseStrategy.parse($0)
        }
        self._formattedValue = State(initialValue: value.wrappedValue.map { format.format($0) } ?? "")
        self.reformat = { value.wrappedValue.map { format.format($0) } ?? "" }
        self.label = label()
        self.icon = icon
        self.prompt = prompt
        self.help = help
    }
}

extension VoltInputField where Label: View, Icon: View {
    package init(
        value: Binding<String>,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder label: () -> Label
    ) {
        self._value = value
        self._formattedValue = State(initialValue: value.wrappedValue)
        self.reformat = nil
        self.label = label()
        self.icon = icon()
        self.prompt = prompt
        self.help = help
    }

    package init<Format: ParseableFormatStyle>(
        value: Binding<Format.FormatInput>,
        format: Format,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder label: () -> Label
    ) where Format.FormatOutput == String {
        self._value = Binding {
            format.format(value.wrappedValue)
        } set: {
            if let parsed = try? format.parseStrategy.parse($0) {
                value.wrappedValue = parsed
            }
        }
        self._formattedValue = State(initialValue: format.format(value.wrappedValue))
        self.reformat = { format.format(value.wrappedValue) }
        self.label = label()
        self.icon = icon()
        self.prompt = prompt
        self.help = help
    }

    package init<Format: ParseableFormatStyle>(
        value: Binding<Format.FormatInput?>,
        format: Format,
        prompt: Text? = nil,
        help: Text? = nil,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder label: () -> Label
    ) where Format.FormatOutput == String {
        self._value = Binding {
            value.wrappedValue.map { format.format($0) } ?? ""
        } set: {
            value.wrappedValue = try? format.parseStrategy.parse($0)
        }
        self._formattedValue = State(initialValue: value.wrappedValue.map { format.format($0) } ?? "")
        self.reformat = { value.wrappedValue.map { format.format($0) } ?? "" }
        self.label = label()
        self.icon = icon()
        self.prompt = prompt
        self.help = help
    }
}
