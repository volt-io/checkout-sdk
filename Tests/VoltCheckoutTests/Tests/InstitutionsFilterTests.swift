//
// InstitutionsFilterTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Institutions Filter Tests")
struct InstitutionsFilterTests {
    let items: [Institution.Item] = [
        Self.makeItem(expectedOrder: 7, name: "Bank"),
        Self.makeItem(expectedOrder: 5, name: "Bank", altName: "Bank"),
        Self.makeItem(expectedOrder: 6, name: "Bank", altName: "Bank", groupName: "Bank"),
        Self.makeItem(expectedOrder: 1, name: "Bank", altName: "Bank", groupName: "Bank", branchName: "Bank"),
        Self.makeItem(expectedOrder: 2, name: "Bank", groupName: "Bank", branchName: "Bank"),
        Self.makeItem(expectedOrder: 3, name: "Bank", branchName: "Bank"),
        Self.makeItem(expectedOrder: 8, name: "Bank", groupName: "Bank"),
        Self.makeItem(expectedOrder: 4, name: "Bank", altName: "Bank", branchName: "Bank"),
    ]

    private static func makeItem(
        expectedOrder: Int,
        name: String,
        altName: String? = nil,
        groupName: String? = nil,
        branchName: String? = nil
    ) -> Institution.Item {
        Institution.Item(
            id: "\(expectedOrder)",
            name: name,
            alternativeName: altName,
            groupName: groupName,
            branchName: branchName,
            logo: nil,
            country: Country(.germany),
            isActive: true,
            accountIdentifiers: [],
        )
    }

    @Test("When strings with diacritics are normalized, then diacritics are converted to ASCII or removed")
    func testStringDiacriticsNormalization() async throws {
        #expect("Zażółć gęślą jaźń".normalized() == "zazoc gesla jazn")
        #expect("Příliš žluťoučký kůň úpěl ďábelské ódy".normalized() == "prilis zlutoucky kun upel dabelske ody")
        #expect("Kŕdeľ ďatľov učí koňa žrať kôru".normalized() == "krdel datlov uci kona zrat koru")
        #expect("Árvíztűrő tükörfúrógép".normalized() == "arvizturo tukorfurogep")
        #expect("Învățământul școlii românești e greu".normalized() == "invatamantul scolii romanesti e greu")
        #expect("Četiri ćevapčića žure u džep".normalized() == "cetiri cevapcica zure u dzep")
        #expect("Þrjátíu og þrír þyrnaríkur".normalized() == "rjatiu og rir yrnarikur")
        #expect("L’élève très âgé fête Noël à côté du cœur".normalized() == "leleve tres age fete noel a cote du cur")
        #expect("Falsches Üben von Xylophonmusik quält jeden größeren Zwerg".normalized() == "falsches uben von xylophonmusik qualt jeden groeren zwerg")
        #expect("El pingüino comía piñón en el sofá".normalized() == "el pinguino comia pinon en el sofa")
    }

    @Test("When normalizing strings, then they are lowercased, and whitespaces are removed")
    func testStringCaseAndTrimNormalization() async throws {
        #expect(" A&B Bank  ".normalized() == "a&b bank")
    }

    @Test("When comparing weighted scores, then higher weight is greater than score")
    func testComparatorWeightOverScore() {
        let lhs = FilterInstitutionsUseCase.WeightedScore(score: 8, weight: 4)
        let rhs = FilterInstitutionsUseCase.WeightedScore(score: 100, weight: 1)

        #expect(lhs > rhs)
    }

    @Test("When comparing scores with equal weights, then score value is compared")
    func testComparatorEqualWeights() {
        let lhs = FilterInstitutionsUseCase.WeightedScore(score: 8, weight: 4)
        let rhs = FilterInstitutionsUseCase.WeightedScore(score: 80, weight: 4)

        #expect(lhs < rhs)
    }

    @Test("When comparing scores with same values, then they are considered equal")
    func testComparatorEqualWeightsAndScores() {
        let lhs = FilterInstitutionsUseCase.WeightedScore(score: 8, weight: 4)
        let rhs = FilterInstitutionsUseCase.WeightedScore(score: 8, weight: 4)

        #expect(lhs == rhs)
    }

    @Test("When filtering institutions with empty query, then original list is returned")
    func testFilterWithEmptyQuery() async throws {
        @Dependency(\.filterInstitutions.filter) var filter

        #expect(filter(items, "") == items)
        #expect(filter(items, " ł ") == items)
    }

    @Test("When filtering institutions, then weights are applied correctly")
    func testFilterWeightSorting() async throws {
        @Dependency(\.filterInstitutions.filter) var filter

        let filtered = filter(items, "bank")

        #expect(filtered.count == items.count)
        #expect(filtered.map(\.id).compactMap(Int.init) == Array(1...8))
    }
}
