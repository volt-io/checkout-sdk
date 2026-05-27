//
// FuzzyMatcher.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 29/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// Implementation of fuzzy search algorithm.
/// Heavily based on https://github.com/forrestthewoods/lib_fts/blob/master/code/fts_fuzzy_match.js
struct FuzzyMatcher {
    typealias Result = (isFound: Bool, score: Int)

    let configuration: Configuration

    func score(for needle: String, in string: String) -> Int {
        var matches = [String.Index]()

        return isMatchingRecursive(
            needle: needle.utf8,
            string: string.utf8,
            needleIndex: needle.startIndex,
            stringIndex: string.startIndex,
            matches: &matches,
            recursionCount: 0,
        ).score
    }

    // swiftlint:disable function_parameter_count
    private func isMatchingRecursive(
        needle: String.UTF8View,
        string: String.UTF8View,
        needleIndex: String.Index,
        stringIndex: String.Index,
        matches: inout [String.Index],
        recursionCount: Int,
    ) -> Result {
        // Recursion limit reached
        guard recursionCount + 1 < configuration.recursionLimit else {
            return (false, 0)
        }

        // Needle fully matched, score path
        guard needleIndex < needle.endIndex else {
            return (true, score(matches: matches, in: string))
        }

        // String exhausted, no match
        guard stringIndex < string.endIndex else {
            return (false, 0)
        }

        var bestScore = 0
        var bestMatches = [String.Index]()
        var stringIndex = stringIndex
        var isMatched = false

        while stringIndex < string.endIndex {
            if needle[needleIndex] == string[stringIndex] {
                // Look for other, potentially better matches, further down the string
                let save = matches
                let (downstreamMatched, downstreamScore) = isMatchingRecursive(
                    needle: needle,
                    string: string,
                    needleIndex: needleIndex,
                    stringIndex: string.index(after: stringIndex),
                    matches: &matches,
                    recursionCount: recursionCount + 1,
                )
                if downstreamMatched, downstreamScore > bestScore {
                    bestScore = downstreamScore
                    bestMatches = matches
                    isMatched = true
                }
                matches = save

                guard matches.count < configuration.maxMatches else {
                    return (false, 0)
                }

                // Explore current match branch further
                matches.append(stringIndex)
                let (branchMatched, branchScore) = isMatchingRecursive(
                    needle: needle,
                    string: string,
                    needleIndex: needle.index(after: needleIndex),
                    stringIndex: string.index(after: stringIndex),
                    matches: &matches,
                    recursionCount: recursionCount + 1,
                )
                if branchMatched, branchScore > bestScore {
                    bestScore = branchScore
                    bestMatches = matches
                    isMatched = true
                }
                _ = matches.popLast()
            }
            stringIndex = string.index(after: stringIndex)
        }

        if isMatched, !bestMatches.isEmpty {
            matches = bestMatches
            return (true, bestScore)
        }
        return (false, 0)
    }
    // swiftlint:enable function_parameter_count

    private func score(matches: [String.Index], in string: String.UTF8View) -> Int {
        guard !matches.isEmpty else { return 0 }

        var score = 100

        let leadingDistance = string.distance(from: string.startIndex, to: matches[0])
        score += min(leadingDistance * configuration.leadingLetterPenalty, configuration.maxLeadingLetterPenalty)

        let unmatched = string.count - matches.count
        score += configuration.unmatchedLetterPenalty * unmatched

        for i in 0..<matches.count {
            let currentIndex = matches[i]

            if i > 0, matches[i - 1] == string.index(before: currentIndex) {
                score += configuration.sequentialBonus
            }

            if currentIndex == string.startIndex {
                score += configuration.firstLetterBonus
            } else if string[string.index(before: currentIndex)] == " ".utf8.first {
                score += configuration.whitespaceBonus
            }
        }

        return score
    }
}

extension FuzzyMatcher {
    struct Configuration {
        /// Maximum length of match within a string
        let maxMatches: Int

        /// Maximum recursion depth
        let recursionLimit: Int

        /// Bonus for adjacent matches
        let sequentialBonus: Int

        /// Bonus if match occurs after a whitespace
        let whitespaceBonus: Int

        /// Bonus if the first letter is matched
        let firstLetterBonus: Int

        /// Penalty applied for every letter in string before the first match
        let leadingLetterPenalty: Int

        /// Maximum penalty for leading letters
        let maxLeadingLetterPenalty: Int

        /// Penalty for unmatched letter
        let unmatchedLetterPenalty: Int
    }
}

extension FuzzyMatcher.Configuration {
    static let `default` = Self(
        maxMatches: 128,
        recursionLimit: 20,
        sequentialBonus: 15,
        whitespaceBonus: 20,
        firstLetterBonus: 25,
        leadingLetterPenalty: -5,
        maxLeadingLetterPenalty: -15,
        unmatchedLetterPenalty: -1
    )
}
