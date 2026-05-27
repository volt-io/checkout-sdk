//
// AccountIdentifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 30/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
@testable import VoltCheckout

@Suite("Account Identifier Tests")
struct AccountIdentifierTests {

    // MARK: - IBAN

    @Suite("IBAN Parsing")
    struct IBANParsing {
        @Test("When initialized from raw string, then country and BBAN are extracted correctly")
        func testRawValueParsing() {
            let iban = IBAN(rawValue: "DE89370400440532013000")
            #expect(iban.country == Locale.Region("DE"))
            #expect(iban.BBAN == "89370400440532013000")
        }

        @Test("When initialized from raw string with spaces, then spaces are stripped")
        func testRawValueParsingStripsSpaces() {
            let iban = IBAN(rawValue: "DE89 3704 0044 0532 0130 00")
            #expect(iban.country == Locale.Region("DE"))
            #expect(iban.BBAN == "89370400440532013000")
        }

        @Test("When rawValue is read back, then it equals country code + BBAN with no spaces")
        func testRawValue() {
            let iban = IBAN(rawValue: "DE89370400440532013000")
            #expect(iban.rawValue == "DE89370400440532013000")
        }

        @Test("When sanitizedValue is read, then only ASCII letters and digits remain")
        func testSanitizedValue() {
            let iban = IBAN(rawValue: "DE89 3704 0044 0532 0130 00")
            #expect(iban.sanitizedValue == "DE89370400440532013000")
        }

        @Test("When initialized via string literal, then it produces the same result as rawValue init")
        func testStringLiteralInit() {
            let literal: IBAN = "DE89370400440532013000"
            let rawValue = IBAN(rawValue: "DE89370400440532013000")
            #expect(literal == rawValue)
        }
    }

    @Suite("IBAN Formatting")
    struct IBANFormatting {
        @Test("When formatted with IBANFormatStyle, then characters are grouped in blocks of four")
        func testFormatStyle() {
            let iban: IBAN = "GB82WEST12345698765432"
            let formatted = iban.formatted(.iban)
            #expect(formatted == "GB82 WEST 1234 5698 7654 32")
        }

        @Test("When parsing a formatted string, then it round-trips back to the original raw value")
        func testParseStrategyRoundTrip() {
            let original: IBAN = "DE89370400440532013000"
            let formatted = original.formatted(.iban)
            let parsed = IBAN.IBANParseStrategy().parse(formatted)
            #expect(parsed == original)
        }
    }

    @Suite("IBAN Partial Validation")
    struct IBANPartialValidation {
        let style = IBAN.IBANValidationStyle()

        @Test("When value is nil, then partial validation is valid")
        func testPartialValidNil() {
            #expect(style.validatePartial(nil) == .valid)
        }

        @Test("When value is empty string, then partial validation is valid")
        func testPartialValidEmpty() {
            #expect(style.validatePartial("") == .valid)
        }

        @Test("When value is a valid IBAN, then partial validation is valid")
        func testPartialValidIBAN() {
            #expect(style.validatePartial("DE89370400440532013000") == .valid)
        }

        @Test("When value contains lowercase letters, then partial validation is invalid")
        func testPartialInvalidContainsLowercase() {
            let result = style.validatePartial("de89370400440532013000")
            #expect(result.isValid == false)
        }

        @Test("When value starts with digits instead of letters, then partial validation is invalid")
        func testPartialInvalidStartsWithDigits() {
            let result = style.validatePartial("1234370400440532013000")
            #expect(result.isValid == false)
        }

        @Test("When value contains special characters, then partial validation is invalid")
        func testPartialInvalidSpecialCharacters() {
            let result = style.validatePartial("DE!9370400440532013000")
            #expect(result.isValid == false)
        }
    }

    @Suite("IBAN Full Validation")
    struct IBANFullValidation {
        let style = IBAN.IBANValidationStyle()

        @Test("When value is nil, then full validation is invalid")
        func testFullValidationNil() {
            #expect(style.validate(nil).isValid == false)
        }

        @Test("When value is empty string, then full validation is invalid")
        func testFullValidationEmpty() {
            #expect(style.validate("").isValid == false)
        }

        @Test("When value is a valid IBAN, then full validation is valid")
        func testFullValidationValidIBAN() {
            #expect(style.validate("DE89370400440532013000") == .valid)
        }

        @Test("When value has only a country code and no BBAN, then full validation is invalid")
        func testFullValidationOnlyCountryCode() {
            #expect(style.validate("DE").isValid == false)
        }

        @Test("When value contains lowercase letters, then full validation is invalid")
        func testFullValidationInvalidContainsLowercase() {
            let result = style.validatePartial("de89370400440532013000")
            #expect(result.isValid == false)
        }

        @Test("When value starts with digits instead of letters, then full validation is invalid")
        func testFullValidationInvalidCountryCode() {
            #expect(style.validate("1289370400440532013000").isValid == false)
        }

        @Test("When value contains lowercase letters, then full validation is invalid")
        func testFullValidationLowercase() {
            #expect(style.validate("de89370400440532013000").isValid == false)
        }

        @Test("When value contains special characters, then full validation is invalid")
        func testFullValidationSpecialCharacters() {
            #expect(style.validate("DE89-3704004405320130-00").isValid == false)
        }

        @Test("When value exceeds max length, then full validation is invalid")
        func testFullValidationExceedsMaxLength() {
            #expect(style.validate("DE893704004405320130001234567890135").isValid == false)
        }
    }

    // MARK: - BranchCode

    @Suite("BranchCode Formatting")
    struct BranchCodeFormatting {
        @Test("When formatted with BranchCodeFormatStyle, then rawValue is returned")
        func testFormatStyle() {
            let branch: BranchCode = "042"
            let formatted = branch.formatted(.branchCode)
            #expect(formatted == "042")
        }

        @Test("When parsing a formatted string, then it round-trips back to the original value")
        func testParseStrategyRoundTrip() throws {
            let original: BranchCode = "042"
            let formatted = original.formatted(.branchCode)
            let parsed = BranchCode.BranchCodeParseStrategy().parse(formatted)
            #expect(parsed == original)
        }
    }

    @Suite("BranchCode Parsing")
    struct BranchCodeParsing {
        @Test("When initialized from a raw string, then code is stored as-is")
        func testRawValueParsing() {
            let branch = BranchCode(rawValue: "123")
            #expect(branch.code == "123")
        }

        @Test("When rawValue is read back, then it equals the stored code")
        func testRawValue() {
            let branch = BranchCode(rawValue: "042")
            #expect(branch.rawValue == "042")
        }

        @Test("When sanitizedValue is read, then letters are stripped and result is truncated to 3 digits")
        func testSanitizedValue() {
            let branch = BranchCode(rawValue: "1a2b3c4")
            #expect(branch.sanitizedValue == "123")
        }

        @Test("When initialized via string literal, then it produces the same result as rawValue init")
        func testStringLiteralInit() {
            let literal: BranchCode = "042"
            let rawValue = BranchCode(rawValue: "042")
            #expect(literal == rawValue)
        }
    }

    @Suite("BranchCode Partial Validation")
    struct BranchCodePartialValidation {
        let style = BranchCode.BranchCodeValidationStyle()

        @Test("When value is nil, then partial validation is valid")
        func testPartialValidNil() {
            #expect(style.validatePartial(nil) == .valid)
        }

        @Test("When value is empty string, then partial validation is valid")
        func testPartialValidEmpty() {
            #expect(style.validatePartial("") == .valid)
        }

        @Test("When value is an exact 3 digit number, then partial validation is valid")
        func testPartialValidCode() {
            #expect(style.validatePartial("123") == .valid)
        }

        @Test("When value is fewer than 3 digits, then partial validation is invalid")
        func testPartialInvalidTooShort() {
            #expect(style.validatePartial("1").isValid == false)
            #expect(style.validatePartial("12").isValid == false)
        }

        @Test("When value contains letters, then partial validation is invalid")
        func testPartialInvalidLetters() {
            #expect(style.validatePartial("1a2").isValid == false)
        }

        @Test("When value exceeds 3 digits, then partial validation is invalid")
        func testPartialInvalidTooLong() {
            #expect(style.validatePartial("1234").isValid == false)
        }
    }

    @Suite("BranchCode Full Validation")
    struct BranchCodeFullValidation {
        let style = BranchCode.BranchCodeValidationStyle()

        @Test("When value is nil, then full validation is invalid")
        func testFullValidationNil() {
            #expect(style.validate(nil).isValid == false)
        }

        @Test("When value is empty string, then full validation is invalid")
        func testFullValidationEmpty() {
            #expect(style.validate("").isValid == false)
        }

        @Test("When value is an exact 3 digit number, then full validation is valid")
        func testFullValidationValid() {
            #expect(style.validate("123") == .valid)
        }

        @Test("When value is fewer than 3 digits, then full validation is invalid")
        func testFullValidationTooShort() {
            #expect(style.validate("1").isValid == false)
            #expect(style.validate("12").isValid == false)
        }

        @Test("When value contains letters, then full validation is invalid")
        func testFullValidationLetters() {
            #expect(style.validate("1a2").isValid == false)
        }

        @Test("When value exceeds 3 digits, then full validation is invalid")
        func testFullValidationTooLong() {
            #expect(style.validate("1234").isValid == false)
        }
    }

    // MARK: - PSUId

    @Suite("PSUId Formatting")
    struct PSUIdFormatting {
        @Test("When formatted with PSUIdFormatStyle, then rawValue is returned")
        func testFormatStyle() {
            let psu: PSUId = "user@bank123"
            let formatted = psu.formatted(.psuId)
            #expect(formatted == "user@bank123")
        }

        @Test("When parsing a formatted string, then it round-trips back to the original value")
        func testParseStrategyRoundTrip() throws {
            let original: PSUId = "user@bank123"
            let formatted = original.formatted(.psuId)
            let parsed = PSUId.PSUIdParseStrategy().parse(formatted)
            #expect(parsed == original)
        }
    }

    @Suite("PSUId Parsing")
    struct PSUIdParsing {
        @Test("When initialized from a raw string, then id is stored as-is")
        func testRawValueParsing() {
            let psu = PSUId(rawValue: "user@bank123")
            #expect(psu.id == "user@bank123")
        }

        @Test("When rawValue is read back, then it equals the stored id")
        func testRawValue() {
            let psu = PSUId(rawValue: "user@bank123")
            #expect(psu.rawValue == "user@bank123")
        }

        @Test("When sanitizedValue is read, then special characters are stripped and result is truncated to 255 chars")
        func testSanitizedValue() {
            let psu = PSUId(rawValue: "user!@#bank")
            #expect(psu.sanitizedValue == "user@bank")
        }

        @Test("When sanitizedValue is read from a string exceeding max length, then it is truncated to 255 chars")
        func testSanitizedValueTruncation() {
            let tooLong = String(repeating: "a", count: 256)
            let psu = PSUId(rawValue: tooLong)
            #expect(psu.sanitizedValue.count == 255)
        }

        @Test("When initialized via string literal, then it produces the same result as rawValue init")
        func testStringLiteralInit() {
            let literal: PSUId = "user@bank123"
            let rawValue = PSUId(rawValue: "user@bank123")
            #expect(literal == rawValue)
        }
    }

    @Suite("PSUId Partial Validation")
    struct PSUIdPartialValidation {
        let style = PSUId.PSUIdValidationStyle()

        @Test("When value is nil, then partial validation is valid")
        func testPartialValidNil() {
            #expect(style.validatePartial(nil) == .valid)
        }

        @Test("When value is empty string, then partial validation is valid")
        func testPartialValidEmpty() {
            #expect(style.validatePartial("") == .valid)
        }

        @Test("When value contains letters, digits and @, then partial validation is valid")
        func testPartialValidId() {
            #expect(style.validatePartial("user@bank123") == .valid)
        }

        @Test("When value contains special characters other than @, then partial validation is invalid")
        func testPartialInvalidSpecialCharacters() {
            #expect(style.validatePartial("user!bank").isValid == false)
        }
    }

    @Suite("PSUId Full Validation")
    struct PSUIdFullValidation {
        let style = PSUId.PSUIdValidationStyle()

        @Test("When value is nil, then full validation is invalid")
        func testFullValidationNil() {
            #expect(style.validate(nil).isValid == false)
        }

        @Test("When value is empty string, then full validation is invalid")
        func testFullValidationEmpty() {
            #expect(style.validate("").isValid == false)
        }

        @Test("When value contains letters, digits and @, then full validation is valid")
        func testFullValidationValid() {
            #expect(style.validate("user@bank123") == .valid)
            #expect(style.validate("ABC") == .valid)
            #expect(style.validate("123") == .valid)
        }

        @Test("When value contains special characters other than @, then full validation is invalid")
        func testFullValidationSpecialCharacters() {
            #expect(style.validate("user!bank").isValid == false)
        }

        @Test("When value exceeds 255 characters, then full validation is invalid")
        func testFullValidationTooLong() {
            let tooLong = String(repeating: "a", count: 256)
            #expect(style.validate(tooLong).isValid == false)
        }
    }

    // MARK: - AccountNumber

    @Suite("AccountNumber Static Methods")
    struct AccountNumberStaticMethods {
        @Test("When country is GB, then prompt returns 8-digit placeholder")
        func testPromptGB() {
            #expect(AccountNumber.prompt(for: .unitedKingdom) == "12345678")
        }

        @Test("When country is not GB, then prompt returns 7-digit placeholder")
        func testPromptEU() {
            #expect(AccountNumber.prompt(for: .germany) == "1234567")
        }

        @Test("When country is GB, then helpMessage returns 8 digit number")
        func testHelpMessageGB() {
            #expect(AccountNumber.helpMessage(for: .unitedKingdom) == "8 digit number")
        }

        @Test("When country is not GB, then helpMessage returns 7 digit number")
        func testHelpMessageEU() {
            #expect(AccountNumber.helpMessage(for: .germany) == "7 digit number")
        }
    }

    @Suite("AccountNumber Formatting")
    struct AccountNumberFormatting {
        @Test("When formatted with AccountNumberFormatStyle, then the number string is returned")
        func testFormatStyle() {
            let account = AccountNumber(countryCode: .unitedKingdom, number: "12345678")
            let formatted = account.formatted(.accountNumber(.unitedKingdom))
            #expect(formatted == "12345678")
        }

        @Test("When parsing a formatted string, then it round-trips back to the original value")
        func testParseStrategyRoundTrip() throws {
            let original = AccountNumber(countryCode: .germany, number: "1234567")
            let formatted = original.formatted(.accountNumber(.germany))
            let parsed = AccountNumber.AccountNumberParseStrategy(countryCode: .germany).parse(formatted)
            #expect(parsed == original)
        }
    }

    @Suite("AccountNumber Properties")
    struct AccountNumberProperties {
        @Test("When country is GB, then maxLength is 8")
        func testMaxLengthGB() {
            let account = AccountNumber(countryCode: .unitedKingdom, number: "12345678")
            #expect(account.maxLength == 8)
        }

        @Test("When country is not GB, then maxLength is 7")
        func testMaxLengthEU() {
            let account = AccountNumber(countryCode: .germany, number: "1234567")
            #expect(account.maxLength == 7)
        }

        @Test("When sanitizedValue is read for GB, then letters are stripped and result is truncated to 8 digits")
        func testSanitizedValueGB() {
            let account = AccountNumber(countryCode: .unitedKingdom, number: "1a23456789")
            #expect(account.sanitizedValue == "12345678")
        }

        @Test("When sanitizedValue is read for EU, then letters are stripped and result is truncated to 7 digits")
        func testSanitizedValueEU() {
            let account = AccountNumber(countryCode: .germany, number: "1a2345678")
            #expect(account.sanitizedValue == "1234567")
        }
    }

    @Suite("AccountNumber GB Partial Validation")
    struct AccountNumberGBPartialValidation {
        let style = AccountNumber.AccountNumberValidationStyle(countryCode: .unitedKingdom)

        @Test("When value is nil, then partial validation is valid")
        func testPartialValidNil() {
            #expect(style.validatePartial(nil) == .valid)
        }

        @Test("When value is empty string, then partial validation is valid")
        func testPartialValidEmpty() {
            #expect(style.validatePartial("") == .valid)
        }

        @Test("When value is an exact 8 digit number, then partial validation is valid")
        func testPartialValidCode() {
            #expect(style.validatePartial("12345678") == .valid)
        }

        @Test("When value is fewer than 8 digits, then partial validation is invalid")
        func testPartialInvalidTooShort() {
            #expect(style.validatePartial("1234567").isValid == false)
        }

        @Test("When value contains letters, then partial validation is invalid")
        func testPartialInvalidLetters() {
            #expect(style.validatePartial("1234a678").isValid == false)
        }

        @Test("When value exceeds 8 digits, then partial validation is invalid")
        func testPartialInvalidTooLong() {
            #expect(style.validatePartial("123456789").isValid == false)
        }
    }

    @Suite("AccountNumber GB Full Validation")
    struct AccountNumberGBFullValidation {
        let style = AccountNumber.AccountNumberValidationStyle(countryCode: .unitedKingdom)

        @Test("When value is nil, then full validation is invalid")
        func testFullValidationNil() {
            #expect(style.validate(nil).isValid == false)
        }

        @Test("When value is empty string, then full validation is invalid")
        func testFullValidationEmpty() {
            #expect(style.validate("").isValid == false)
        }

        @Test("When value is an exact 8 digit number, then full validation is valid")
        func testFullValidationValid() {
            #expect(style.validate("12345678") == .valid)
        }

        @Test("When value is fewer than 8 digits, then full validation is invalid")
        func testFullValidationTooShort() {
            #expect(style.validate("1234567").isValid == false)
        }

        @Test("When value exceeds 8 digits, then full validation is invalid")
        func testFullValidationTooLong() {
            #expect(style.validate("123456789").isValid == false)
        }

        @Test("When value contains letters, then full validation is invalid")
        func testFullValidationLetters() {
            #expect(style.validate("1234a678").isValid == false)
        }
    }

    @Suite("AccountNumber EU Partial Validation")
    struct AccountNumberEUPartialValidation {
        let style = AccountNumber.AccountNumberValidationStyle(countryCode: .germany)

        @Test("When value is nil, then partial validation is valid")
        func testPartialValidNil() {
            #expect(style.validatePartial(nil) == .valid)
        }

        @Test("When value is empty string, then partial validation is valid")
        func testPartialValidEmpty() {
            #expect(style.validatePartial("") == .valid)
        }

        @Test("When value is an exact 7 digit number, then partial validation is valid")
        func testPartialValidCode() {
            #expect(style.validatePartial("1234567") == .valid)
        }

        @Test("When value is fewer than 7 digits, then partial validation is invalid")
        func testPartialInvalidTooShort() {
            #expect(style.validatePartial("123456").isValid == false)
        }

        @Test("When value exceeds 7 digits, then partial validation is invalid")
        func testPartialInvalidTooLong() {
            #expect(style.validatePartial("12345678").isValid == false)
        }

        @Test("When value contains letters, then partial validation is invalid")
        func testPartialInvalidLetters() {
            #expect(style.validatePartial("123a567").isValid == false)
        }
    }

    @Suite("AccountNumber EU Full Validation")
    struct AccountNumberEUFullValidation {
        let style = AccountNumber.AccountNumberValidationStyle(countryCode: .germany)

        @Test("When value is nil, then full validation is invalid")
        func testFullValidationNil() {
            #expect(style.validate(nil).isValid == false)
        }

        @Test("When value is empty string, then full validation is invalid")
        func testFullValidationEmpty() {
            #expect(style.validate("").isValid == false)
        }

        @Test("When value is an exact 7 digit number, then full validation is valid")
        func testFullValidationValid() {
            #expect(style.validate("1234567") == .valid)
        }

        @Test("When value is fewer than 7 digits, then full validation is invalid")
        func testFullValidationTooShort() {
            #expect(style.validate("123456").isValid == false)
        }

        @Test("When value exceeds 7 digits, then full validation is invalid")
        func testFullValidationTooLong() {
            #expect(style.validate("12345678").isValid == false)
        }

        @Test("When value contains letters, then full validation is invalid")
        func testFullValidationLetters() {
            #expect(style.validate("123a567").isValid == false)
        }
    }
}
