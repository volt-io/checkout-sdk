//
// EnvironmentValues+Countries.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var selectedCountry: Country?
    @Entry var onTapCancel: () -> Void = { }
    @Entry var onTapCountry: (Country) -> Void = { _ in }
}
