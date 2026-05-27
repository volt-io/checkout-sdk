//
// GroupInstitutionsUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 13/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct GroupInstitutionsUseCase {
    var group: @Sendable (_ items: [Institution.Item]) -> [Institution.Group] = { _ in [] }
}

extension GroupInstitutionsUseCase: DependencyKey {
    static let liveValue = Self { items in
        // Create array of unique group names with preserved order
        var seen = Set<String>()
        let groupNames: [String] = items
            .map { $0.groupName ?? $0.name }
            .filter { seen.insert($0).inserted }

        // Group items using dictionary, because it's fast
        let groupedItems = Dictionary(grouping: items, by: { $0.groupName ?? $0.name })

        // Map names to groups adding branches from dictionary
        return groupNames.map { groupName in
            Institution.Group(
                name: groupName,
                branches: groupedItems[groupName] ?? []
            )
        }
    }
}

extension DependencyValues {
    var groupInstitutions: GroupInstitutionsUseCase {
        get { self[GroupInstitutionsUseCase.self] }
        set { self[GroupInstitutionsUseCase.self] = newValue }
    }
}

extension GroupInstitutionsUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}
