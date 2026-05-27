//
// InstitutionsFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 30/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct InstitutionsFeature {
    @ObservableState
    struct State: Equatable {
        let currency: Currency
        let defaultCountry: Country?

        var selectedCountry: Country?
        var countries: [Country] = []
        var groups: [Institution.Group] = []
        var items: [Institution.Item] = []
        
        var loadingState: LoadingState = .notStarted
        var error: String?
        var searchQuery = ""
        var popoverItem: Institution.Item?
        var isCountriesSheetPresented = false
        
        var navBar: CheckoutNavBarFeature.State = .backButtonHidden(with: InstitutionsFeedback())
    }
    
    enum Action {
        case onAppear
        case onStartLoading
        case onError(String)
        
        case onCountriesChanged([Country])
        case onPresentingCountrySelection(Bool)
        case onSelectedCountryChanged(Country)
        
        case onInstitutionsChanged([Institution.Item], [Institution.Group])
        case onTappedInstitution(Institution.Item)
        case onTappedGroup(Institution.Group)
        case onSearchQueryChanged(String)
        case onPopoverItemChanged(Institution.Item?)
        
        case navBar(CheckoutNavBarFeature.Action)
    }

    enum LoadingState: Equatable {
        case notStarted, loading, finished
    }

    @Dependency(\.voltAPI.getInstitutions) var getInstitutions
    @Dependency(\.filterInstitutions.filter) var filterInstitutions
    @Dependency(\.groupInstitutions.group) var groupInstitutions
    @Dependency(\.countries.getCountries) var getCountries
    @Dependency(\.countries.preselectCountry) var preselectCountry
    
    var body: some ReducerOf<Self> {
        Scope(state: \.navBar, action: \.navBar) {
            CheckoutNavBarFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                handleOnAppear(with: &state)
            case .onStartLoading:
                handleOnStartLoading(with: &state)
            case let .onError(error):
                handleOnError(with: &state, error)
            case let .onCountriesChanged(countries):
                handleOnCountriesChanged(with: &state, countries)
            case let .onPresentingCountrySelection(isPresented):
                handleOnPresentingCountrySelection(with: &state, isPresented)
            case let .onSelectedCountryChanged(country):
                handleOnSelectedCountryChanged(with: &state, country)
            case let .onInstitutionsChanged(items, groups):
                handleOnInstitutionsChanged(with: &state, items, groups)
            case let .onSearchQueryChanged(query):
                handleOnSearchQueryChanged(with: &state, query: query)
            case let .onTappedInstitution(item):
                handleOnTappedInstitution(with: &state, item: item)
            case let .onPopoverItemChanged(item):
                handleOnPopoverItemChanged(with: &state, item: item)
            case .navBar(.delegate(.onDismissFeedback)):
                handleOnFeedbackSheetDismissed(with: &state)
            default:
                .none
            }
        }
    }
    
    func handleOnAppear(with state: inout State) -> Effect<Action> {
        if case .notStarted = state.loadingState {
            return .send(.onStartLoading)
        }
        return .none
    }

    func handleOnStartLoading(with state: inout State) -> Effect<Action> {
        state.loadingState = .loading
        state.popoverItem = nil
        state.error = nil

        let currency = state.currency

        return .run { send in
            let countries = try await getCountries(currency)
            await send(.onCountriesChanged(countries))
        } catch: { error, send in
            await send(.onError(error.localizedDescription))
        }
    }
    
    func handleOnError(with state: inout State, _ error: String) -> Effect<Action> {
        state.isCountriesSheetPresented = false
        state.loadingState = .finished
        state.popoverItem = nil
        state.error = error
        state.countries = []
        state.groups = []
        state.items = []
        return .none
    }
    
    func handleOnCountriesChanged(with state: inout State, _ countries: [Country]) -> Effect<Action> {
        state.countries = countries

        if let country = preselectCountry(state.defaultCountry, countries) {
            return .send(.onSelectedCountryChanged(country), animation: .default)
        }
        return .send(.onPresentingCountrySelection(true))
    }
    
    func handleOnPresentingCountrySelection(with state: inout State, _ isPresented: Bool) -> Effect<Action> {
        state.isCountriesSheetPresented = isPresented
        return .none
    }
    
    func handleOnSelectedCountryChanged(with state: inout State, _ country: Country) -> Effect<Action> {
        state.isCountriesSheetPresented = false
        state.loadingState = .loading
        state.popoverItem = nil
        state.error = nil
        state.groups = []
        state.items = []
        state.selectedCountry = country
        
        let currency = state.currency
        
        return .run { send in
            let items = try await getInstitutions(currency, country)
            let groups = groupInstitutions(items)
            await send(.onInstitutionsChanged(items, groups), animation: .default)
        } catch: { error, send in
            await send(.onError(error.localizedDescription))
        }
    }
    
    func handleOnInstitutionsChanged(
        with state: inout State,
        _ items: [Institution.Item],
        _ groups: [Institution.Group]
    ) -> Effect<Action> {
        state.loadingState = .finished
        state.popoverItem = nil
        state.items = items
        state.groups = groups
        
        return .none
    }
    
    func handleOnSearchQueryChanged(with state: inout State, query: String) -> Effect<Action> {
        state.popoverItem = nil
        state.searchQuery = query

        let groups = groupInstitutions(filterInstitutions(state.items, query))
        return .send(.onInstitutionsChanged(state.items, groups), animation: .default)
    }
    
    func handleOnTappedInstitution(with _: inout State, item: Institution.Item) -> Effect<Action> {
        .send(.onPopoverItemChanged(!item.isActive ? item : nil))
    }
    
    func handleOnPopoverItemChanged(with state: inout State, item: Institution.Item?) -> Effect<Action> {
        state.popoverItem = item
        return .none
    }

    func handleOnFeedbackSheetDismissed(with state: inout State) -> Effect<Action> {
        if state.selectedCountry == nil {
            return .send(.onStartLoading)
        }
        return .none
    }
}
