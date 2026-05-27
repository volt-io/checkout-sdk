//
// InstitutionsCountriesTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 08/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import TestSupport
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Institutions Countries Tests")
struct InstitutionsCountriesTests {

    @Test("When preselecting with one country on the list, then this country is returned")
    func preselectingWithOneCountry() async throws {
        let expected = Country(.poland)
        let countries = [Country(.poland)]

        let sut = InstitutionsCountriesUseCase.testValue
        let result = sut.preselectCountry(defaultCountry: nil, countries: countries)

        #expect(result == expected)
    }

    @Test("When preselecting with default country on the list, then this country is returned")
    func preselectingWithDefaultOnList() async throws {
        let pl = Country(.poland)
        let de = Country(.germany)

        let sut = InstitutionsCountriesUseCase.testValue
        let result = sut.preselectCountry(defaultCountry: pl, countries: [de, pl])

        #expect(result == pl)
    }

    @Test("When preselecting with default not on the list, then nil is returned")
    func preselectingWithDefaultNotOnList() async throws {
        let pl = Country(.poland)
        let de = Country(.germany)
        let us = Country(.unitedStates)

        let sut = InstitutionsCountriesUseCase.testValue
        let result = sut.preselectCountry(defaultCountry: us, countries: [de, pl])

        #expect(result == nil)
    }

    @Test("When preselecting without default and many on the list, then nil is returned")
    func preselectingWithNoDefault() async throws {
        let countries = [Country(.poland), Country(.andorra), Country(.malta)]

        let sut = InstitutionsCountriesUseCase.testValue
        let result = sut.preselectCountry(defaultCountry: nil, countries: countries)

        #expect(result == nil)
    }

    @Test("When getting countries for currency with 1-1 mapping, then no remote call is made")
    func gettingCountriesReturnsFromMapping() async throws {
        nonisolated(unsafe) var calledRemote = false

        try await withDependencies {
            $0.voltAPI.getInstitutionsCountries = { _ in
                calledRemote = true
                return []
            }
        } operation: {
            let expected = [Country(.romania)]

            let sut = InstitutionsCountriesUseCase.testValue
            let result = try await sut.getCountries(currency: .RON)

            #expect(calledRemote == false)
            #expect(result == expected)
        }
    }

    @Test("When getting countries for currency with 1-many mapping, then it fetches countries from remote")
    func gettingCountriesFetchesFromRemote() async throws {
        nonisolated(unsafe) var calledRemote = false

        try await withDependencies {
            $0.voltAPI.getInstitutionsCountries = { _ in
                calledRemote = true
                return [Country(.germany)]
            }
        } operation: {
            let expected = [Country(.germany)]

            let sut = InstitutionsCountriesUseCase.testValue
            let result = try await sut.getCountries(currency: .EUR)

            #expect(calledRemote == true)
            #expect(result == expected)
        }
    }
}
