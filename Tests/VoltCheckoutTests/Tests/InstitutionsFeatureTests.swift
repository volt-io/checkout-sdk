//
// InstitutionsFeatureTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Testing
import TestSupport
import ComposableArchitecture
@testable import VoltCheckout

@Suite("Institutions Feature Tests")
@MainActor struct InstitutionsFeatureTests {
    enum TestError: Error {
        case getCountriesFailed
        case getInstitutionsFailed
    }

    let countries = try! ResourceReader
        .readJSON("InstitutionsCountries", to: [CountryResponse].self)
        .compactMap { Country.init(rawValue: $0.code) }
    let items = try! ResourceReader
        .readJSON("InstitutionsListDE", to: [InstitutionResponse].self)
        .map(Institution.Item.init(with:))
    var disabledItem: Institution.Item {
        items.first(where: { !$0.isActive })!
    }
    var activeItem: Institution.Item {
        items.first(where: { $0.isActive })!
    }

    @Test("When currency is EUR and no default country, then country selection is shown")
    func testShowingCountrySelectionInitially() async throws {
        let testStore = TestStore(initialState: .init(currency: .EUR, defaultCountry: nil)) {
            InstitutionsFeature()
        }

        await testStore.send(.onAppear)
        await testStore.receive(\.onStartLoading) {
            $0.loadingState = .loading
        }
        await testStore.receive(\.onCountriesChanged) {
            $0.countries = countries
        }
        await testStore.receive(\.onPresentingCountrySelection) {
            $0.isCountriesSheetPresented = true
        }
    }

    @Test("When there's one country for currency, then this country is auto selected and institutions are loaded")
    func testCountryAutoPreselection() async throws {
        let currency = Currency.RON
        let country = Country(.romania)

        let testStore = TestStore(initialState: .init(currency: currency, defaultCountry: nil)) {
            InstitutionsFeature()
        } withDependencies: {
            $0.countries.preselectCountry = { _, _ in country }
            $0.voltAPI.getInstitutions = { _, _ in items }
        }
        let expectedGroups = testStore.dependencies.groupInstitutions.group(items: items)

        await testStore.send(.onAppear)
        await testStore.receive(\.onStartLoading) {
            $0.loadingState = .loading
        }
        await testStore.receive(\.onCountriesChanged) {
            $0.countries = [country]
        }
        await testStore.receive(\.onSelectedCountryChanged) {
            $0.selectedCountry = country
        }
        await testStore.receive(\.onInstitutionsChanged) {
            $0.loadingState = .finished
            $0.items = items
            $0.groups = expectedGroups
        }
    }

    @Test("When searching institutions, then groups are correctly filtered")
    func testSearchingInstitutionsGroupsFiltering() async throws {
        let testStore = TestStore(initialState: .init(currency: .EUR, defaultCountry: Country(.germany))) {
            InstitutionsFeature()
        }
        let searchQuery = "Bank"
        let initialGroups = testStore.dependencies.groupInstitutions.group(items: items)
        let filteredGroups = testStore.dependencies.groupInstitutions.group(
            items: testStore.dependencies.filterInstitutions.filter(items: items, query: searchQuery)
        )

        await testStore.send(.onAppear)
        await testStore.receive(\.onStartLoading) {
            $0.loadingState = .loading
        }
        await testStore.receive(\.onCountriesChanged) {
            $0.countries = countries
        }
        await testStore.receive(\.onSelectedCountryChanged) {
            $0.selectedCountry = Country(.germany)
        }
        await testStore.receive(\.onInstitutionsChanged) {
            $0.loadingState = .finished
            $0.items = items
            $0.groups = initialGroups
        }
        await testStore.send(.onSearchQueryChanged(searchQuery)) {
            $0.searchQuery = searchQuery
        }
        await testStore.receive(\.onInstitutionsChanged) {
            $0.groups = filteredGroups
        }
        await testStore.send(.onSearchQueryChanged("")) {
            $0.searchQuery = ""
        }
        await testStore.receive(\.onInstitutionsChanged) {
            $0.groups = initialGroups
        }
    }

    @Test("When tapping institution, then popover is shown if it's inactive")
    func testTappingInactiveInstitution() async throws {
        let testStore = TestStore(initialState: .init(currency: .EUR, defaultCountry: Country(.germany))) {
            InstitutionsFeature()
        }
        let groups = testStore.dependencies.groupInstitutions.group(items: items)

        await testStore.send(.onAppear)
        await testStore.receive(\.onStartLoading) {
            $0.loadingState = .loading
        }
        await testStore.receive(\.onCountriesChanged) {
            $0.countries = countries
        }
        await testStore.receive(\.onSelectedCountryChanged) {
            $0.selectedCountry = Country(.germany)
        }
        await testStore.receive(\.onInstitutionsChanged) {
            $0.loadingState = .finished
            $0.items = items
            $0.groups = groups
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

    @Test("When getting countries fails, then error is handled")
    func testCountriesErrorHandling() async throws {
        let testStore = TestStore(initialState: .init(currency: .EUR, defaultCountry: nil)) {
            InstitutionsFeature()
        } withDependencies: {
            $0.countries.getCountries = { _ in
                throw TestError.getCountriesFailed
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(.onAppear)
        await testStore.receive(\.onError, TestError.getCountriesFailed.localizedDescription) {
            $0.error = TestError.getCountriesFailed.localizedDescription
        }
    }

    @Test("When getting institutions fails, then error is handled")
    func testInstitutionsErrorHandling() async throws {
        let testStore = TestStore(initialState: .init(currency: .EUR, defaultCountry: nil)) {
            InstitutionsFeature()
        } withDependencies: {
            $0.voltAPI.getInstitutions = { _, _ in
                throw TestError.getInstitutionsFailed
            }
        }
        testStore.exhaustivity = .off

        await testStore.send(.onSelectedCountryChanged(Country(.germany)))
        await testStore.receive(\.onError, TestError.getInstitutionsFailed.localizedDescription) {
            $0.error = TestError.getInstitutionsFailed.localizedDescription
        }
    }
}
