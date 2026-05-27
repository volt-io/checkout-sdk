//
// FuzzyMatcherTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 08/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
@testable import VoltCheckout

@Suite("FuzzyMatcher Tests")
struct FuzzyMatcherScoringTests {
    let cfg = FuzzyMatcher.Configuration.default

    @Test("When there's an exact match, then it's scored higher than partial matches")
    func testExactMatchBeatsOthers() {
        let matcher = FuzzyMatcher(configuration: .default)

        let exact = matcher.score(for: "bank", in: "bank")
        let none = matcher.score(for: "bank", in: "payment")
        let leadingPartial = matcher.score(for: "bank", in: "banking")
        let middlePartial = matcher.score(for: "bank", in: "embankment")
        let trailingPartial = matcher.score(for: "bank", in: "piggybank")

        #expect(exact > none)
        #expect(exact > leadingPartial)
        #expect(exact > middlePartial)
        #expect(exact > trailingPartial)
    }

    @Test("When query or string are empty, then score equals zero")
    func testEmptyInputsScoresZero() {
        let matcher = FuzzyMatcher(configuration: .default)

        #expect(matcher.score(for: "", in: "payment") == 0)
        #expect(matcher.score(for: "bank", in: "") == 0)
        #expect(matcher.score(for: "", in: "") == 0)
    }

    @Test("When query in non-matching order appears in the string, then score equals zero")
    func testReversedInputScoresZero() {
        let matcher = FuzzyMatcher(configuration: .default)

        let score1 = matcher.score(for: "bank", in: "kanban")
        let score2 = matcher.score(for: "abc", in: "cba")

        #expect(score1 == 0)
        #expect(score2 == 0)
    }

    @Test("When case sensitivity doesn't match, then score equals zero")
    func testCaseSensitivityMatter() {
        let matcher = FuzzyMatcher(configuration: .default)

        let lower = matcher.score(for: "bank", in: "bank")
        let mixed = matcher.score(for: "bank", in: "Bank")

        #expect(lower > mixed)
        #expect(mixed == 0)
    }

    @Test("When unicode characters are used, then they are scored just like ASCII")
    func testUnicodeSupport() {
        let matcher = FuzzyMatcher(configuration: .default)

        let emojiExact = matcher.score(for: "🏦", in: "🏦")
        let emojiPartial = matcher.score(for: "🏦", in: "tap 🏦 to pay")
        let emojiMissing = matcher.score(for: "🏦", in: "tap bank to pay")

        #expect(emojiExact > emojiPartial)
        #expect(emojiPartial > emojiMissing)
        #expect(emojiMissing == 0)
    }

    @Test("When match is contiguous, then it scores higher than scattered match")
    func testSequentialBonus() {
        let matcher = FuzzyMatcher(configuration: .default)

        let contiguous = matcher.score(for: "bank", in: "bank roll")
        let scattered = matcher.score(for: "bank", in: "bass link")

        #expect(contiguous > scattered)
    }

    @Test("When first letter is matched, then it scores higher than letter after whitespace")
    func testFirstLetterAndWhitespaceBonuses() {
        let matcher = FuzzyMatcher(configuration: .default)

        let firstLetter = matcher.score(for: "b", in: "bankroll stash")
        let afterSpace = matcher.score(for: "b", in: "stash bankroll")

        #expect(firstLetter > afterSpace)
    }

    @Test("When match occurs early in a string, then it scores higher than one occurring later")
    func testLeadingPenalty() {
        let matcher = FuzzyMatcher(configuration: .default)

        let leading = matcher.score(for: "fast", in: "fast run now")
        let middle = matcher.score(for: "fast", in: "run fast now")
        let trailing = matcher.score(for: "fast", in: "run now fast")

        #expect(leading > middle)
        #expect(middle > trailing)
    }

    @Test("When match occurs in longer string, then it scores lower than one occurring in shorter")
    func testUnmatchedLetterPenalty() {
        let matcher = FuzzyMatcher(configuration: .default)

        let short = matcher.score(for: "bank", in: "bank account")
        let long = matcher.score(for: "bank", in: "bank account to account payment")

        #expect(short > long)
    }
}
