//
// Institution+Item.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 11/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

extension Institution {
    struct Item: Identifiable, Equatable, Hashable, Sendable {
        let id: String
        let name: String
        let alternativeName: String?
        let groupName: String?
        let branchName: String?
        let logo: URL?
        let country: Country
        let isActive: Bool
        let accountIdentifiers: Set<AccountIdentifier>
    }
}

extension Institution.Item {
    init(with response: InstitutionResponse) {
        id = response.id
        name = response.name
        alternativeName = response.alternativeName
        groupName = response.group.name
        branchName = response.branch.name
        logo = URL(string: response.assets.logo)
        country = Country(rawValue: response.country)
        isActive = response.capabilities.payments.active
        accountIdentifiers = Set(
            response.capabilities.payments.accountIdentifiersRequired.map(AccountIdentifier.init(with:))
        )
    }

    var asInstitution: Institution {
        Institution(
            id: id,
            name: branchName ?? name,
            logo: logo,
            country: country
        )
    }
}
