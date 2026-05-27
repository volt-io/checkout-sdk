//
// FilterInstitutionsUseCase.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 21/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct FilterInstitutionsUseCase {
    var filter: @Sendable (_ items: [Institution.Item], _ query: String) -> [Institution.Item] = { _, _ in [] }
}

extension FilterInstitutionsUseCase: DependencyKey {
    static let liveValue = Self { items, query in
        guard let normalizedQuery = query.normalized(), !normalizedQuery.isEmpty else {
            return items
        }

        return items
            .compactMap { item in
                zip([item.name, item.groupName, item.alternativeName, item.branchName], Self.weights)
                    .compactMap { name, weight in
                        guard let name = name?.normalized() else { return nil }
                        let score = Self.fuzzyMatcher.score(for: normalizedQuery, in: name)
                        return WeightedScore(score: score, weight: weight)
                    }
                    .filter { $0.score >= Self.scoreThreshold }
                    .sorted(by: >)
                    .map { ScoredItem(item: item, weightedScore: $0) }
                    .first
            }
            .sorted(by: >)
            .map(\.item)
    }

    private static let fuzzyMatcher = FuzzyMatcher(configuration: .default)
}

extension FilterInstitutionsUseCase {
    static let scoreThreshold = 60
    static let nameWeight = 1
    static let groupNameWeight = 1
    static let alternativeNameWeight = 2
    static let branchNameWeight = 4
    static let weights = [nameWeight, groupNameWeight, alternativeNameWeight, branchNameWeight]

    struct ScoredItem: Comparable {
        let item: Institution.Item
        let weightedScore: WeightedScore

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.weightedScore < rhs.weightedScore
        }
    }

    struct WeightedScore: Equatable, Comparable {
        let score: Int
        let weight: Int

        static let zero = Self(score: 0, weight: 0)

        static func < (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case _ where lhs.weight > rhs.weight:
                return false
            case _ where lhs.weight < rhs.weight:
                return true
            case _ where lhs.score > rhs.score:
                return false
            case _ where lhs.score < rhs.score:
                return true
            default:
                return false
            }
        }
    }
}

extension DependencyValues {
    var filterInstitutions: FilterInstitutionsUseCase {
        get { self[FilterInstitutionsUseCase.self] }
        set { self[FilterInstitutionsUseCase.self] = newValue }
    }
}

extension FilterInstitutionsUseCase: TestDependencyKey {
    static let previewValue = liveValue
    static let testValue = liveValue
}

extension String {
    @inline(__always)
    func asciiValue() -> Self? {
        String(bytes: compactMap(\.asciiValue), encoding: .ascii)
    }

    @inline(__always)
    func normalized() -> Self? {
        self.lowercased()
            .applyingTransform(.stripDiacritics, reverse: false)?
            .asciiValue()?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
