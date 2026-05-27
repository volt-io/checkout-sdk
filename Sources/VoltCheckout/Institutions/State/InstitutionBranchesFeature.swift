//
// InstitutionBranchesFeature.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 25/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct InstitutionBranchesFeature {
    @ObservableState
    struct State: Equatable {
        var navBar: CheckoutNavBarFeature.State = .backButtonVisible(with: InstitutionsFeedback())
        var items: [Institution.Item] = []
        var group: Institution.Group
        var searchQuery = ""
        var popoverItem: Institution.Item?
    }

    enum Action {
        case onAppear
        case onSearchQueryChanged(String)
        case onItemsChanged([Institution.Item])
        case onTappedInstitution(Institution.Item)
        case onPopoverItemChanged(Institution.Item?)
        case navBar(CheckoutNavBarFeature.Action)
    }

    @Dependency(\.filterInstitutions.filter) var filter

    var body: some ReducerOf<Self> {
        Scope(state: \.navBar, action: \.navBar) {
            CheckoutNavBarFeature()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [state] send in
                    await send(.onItemsChanged(state.group.branches))
                }
            case let .onSearchQueryChanged(query):
                state.popoverItem = nil
                state.searchQuery = query
                return .run { [state] send in
                    await send(.onItemsChanged(filter(state.group.branches, query)))
                }
            case let .onItemsChanged(items):
                state.popoverItem = nil
                state.items = items
                return .none
            case let .onTappedInstitution(item):
                return .run { send in
                    await send(.onPopoverItemChanged(!item.isActive ? item : nil))
                }
            case let .onPopoverItemChanged(item):
                state.popoverItem = item
                return .none
            default:
                return .none
            }
        }
    }
}
