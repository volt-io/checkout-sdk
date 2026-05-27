//
// Institution+Group.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 11/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

extension Institution {
    struct Group: Identifiable, Equatable, Hashable, Sendable {
        var id: String { name }
        let name: String
        let branches: [Institution.Item]
        var logo: URL? { branches.first?.logo }
    }
}

extension Institution.Group {
    var isActive: Bool {
        branches.reduce(into: 0, { $0 += Int($1.isActive) }) > 0
    }
}
