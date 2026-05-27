//
// VoltNavigationBackButtonStyle.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 05/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension View {
    package func voltNavigationBackButtonStyle() -> some View {
        modifier(CustomBackItemModifier(
            image: .voltBackIcon,
            imageInsets: .init(top: 0, left: .voltPadding3 * -1, bottom: 0, right: 0),
            displayMode: .minimal
        ))
    }
}
