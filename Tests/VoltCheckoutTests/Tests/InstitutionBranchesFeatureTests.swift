//
// InstitutionBranchesFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import TestSupport
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Institution Branches Feature Tests")
@MainActor struct InstitutionBranchesFeatureTests {
    let group: Institution.Group = {
        @Dependency(\.groupInstitutions.group) var group
        let items = try! ResourceReader
            .readJSON("InstitutionsListDE", to: [InstitutionResponse].self)
            .map(Institution.Item.init(with:))
        return group(items).first(where: { $0.name == "Sparkasse" })!
    }()
    var disabledItem: Institution.Item {
        group.branches.first(where: { !$0.isActive })!
    }
    var activeItem: Institution.Item {
        group.branches.first(where: { $0.isActive })!
    }
    let searchQuery = "bank"

    let testStore: TestStoreOf<InstitutionBranchesFeature>

    init() {
        let state = InstitutionBranchesFeature.State(group: group)
        self.testStore = TestStore(initialState: state) {
            InstitutionBranchesFeature()
        }
    }

    @Test("When sending actions to feature, then state is correctly mutated")
    func testInstitutionBranchesActions() async throws {
        await testStore.send(.onAppear)
        await testStore.receive(\.onItemsChanged) {
            $0.items = group.branches
        }
        await testStore.send(.onSearchQueryChanged(searchQuery)) {
            $0.searchQuery = searchQuery
        }
        await testStore.receive(\.onItemsChanged) {
            $0.items = testStore.dependencies.filterInstitutions.filter(items: group.branches, query: searchQuery)
        }
        await testStore.send(.onSearchQueryChanged("")) {
            $0.searchQuery = ""
        }
        await testStore.receive(\.onItemsChanged) {
            $0.items = group.branches
        }
        await testStore.send(.onTappedInstitution(disabledItem))
        await testStore.receive(\.onPopoverItemChanged) {
            $0.popoverItem = disabledItem
        }
        await testStore.send(.onTappedInstitution(activeItem))
        await testStore.receive(\.onPopoverItemChanged) {
            $0.popoverItem = nil
        }
    }
}
