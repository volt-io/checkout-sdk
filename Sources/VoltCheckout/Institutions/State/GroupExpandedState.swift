//
// GroupExpandedState.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

struct GroupExpandedState: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
