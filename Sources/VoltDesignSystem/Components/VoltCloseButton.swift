//
// VoltCloseButton.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltCloseButton: View {
    package let action: () -> Void

    package init(action: @escaping () -> Void) {
        self.action = action
    }

    package var body: some View {
        Button(action: action) {
            Label {
                Text("Close")
            } icon: {
                Image.voltCloseIcon
            }
            .labelStyle(.voltIconOnly)
        }
    }
}
