//
// EnvironmentValues+Institutions.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var searchQuery = ""
    @Entry var onTapInstitution: (Institution.Item) -> Void = { _ in }
    @Entry var onTapGroup: (Institution.Group) -> Void = { _ in }
}
