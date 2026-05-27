//
// InstitutionsGroupTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Institutions Group Tests")
struct InstitutionsGroupTests {
    private func makeItem(
        name: String,
        alt: String? = nil,
        group: String? = nil,
        branch: String? = nil
    ) -> Institution.Item {
        Institution.Item(
            id: UUID().uuidString,
            name: name,
            alternativeName: alt,
            groupName: group,
            branchName: branch,
            logo: nil,
            country: Country(.germany),
            isActive: true,
            accountIdentifiers: [],
        )
    }

    @Dependency(\.groupInstitutions.group) var group

    @Test("When grouping empty list of items, then resulting list of groups is also empty")
    func testEmptyItemsGivesNoGroups() {
        #expect(group([]).isEmpty)
    }

    @Test("When items has groupName, then it's used for grouping, otherwise name is used")
    func testGroupingKeyPriority() {
        let items = [
            makeItem(name: "Item A", group: "Group 1"),
            makeItem(name: "Item B", group: "Group 1"),
            makeItem(name: "Item C"),
            makeItem(name: "Item D", group: "Group 2"),
        ]

        let groups = group(items)

        #expect(groups.map(\.name) == ["Group 1", "Item C", "Group 2"])
        #expect(groups[0].branches.map(\.name) == ["Item A", "Item B"])
        #expect(groups[1].branches.map(\.name) == ["Item C"])
        #expect(groups[2].branches.map(\.name) == ["Item D"])
    }

    @Test("When creating groups, then order of first appearance of group names is preserved")
    func testGroupOrderPreserved() {
        let items = [
            makeItem(name: "Item A", group: "Group 2"),
            makeItem(name: "Item B", group: "Group 1"),
            makeItem(name: "Item C", group: "Group 2"),
            makeItem(name: "Item D", group: "Group 3"),
            makeItem(name: "Item E", group: "Group 1"),
            makeItem(name: "Item F", group: "Group 3"),
        ]

        let groups = group(items)

        #expect(groups.map(\.name) == ["Group 2", "Group 1", "Group 3"])
    }

    @Test("When creating groups, then order of appearance of items is preserved in group's branches")
    func testBranchOrderPreserved() {
        let items = [
            makeItem(name: "Item A", group: "Group 1"),
            makeItem(name: "Item B", group: "Group 2"),
            makeItem(name: "Item C", group: "Group 1"),
            makeItem(name: "Item D", group: "Group 2"),
            makeItem(name: "Item E", group: "Group 1"),
        ]

        let groups = group(items)

        #expect(groups[0].branches.map(\.name) == ["Item A", "Item C", "Item E"])
        #expect(groups[1].branches.map(\.name) == ["Item B", "Item D"])
    }

    @Test("When creating groups, then each group name is unique")
    func testUniqueKeysFormSingleGroups() {
        let items: [Institution.Item] = [
            makeItem(name: "Item A"),
            makeItem(name: "Item B"),
            makeItem(name: "Item C"),
            makeItem(name: "Item D", group: "Item A"),
        ]

        let groups = group(items)

        #expect(groups.count == 3)
        #expect(groups.map(\.name) == ["Item A", "Item B", "Item C"])
    }
}
