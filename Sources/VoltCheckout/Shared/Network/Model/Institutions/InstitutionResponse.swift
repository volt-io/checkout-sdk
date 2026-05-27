//
// InstitutionResponse.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct InstitutionResponse: Codable {
    let id: String
    let country: String
    let name: String
    let localName: String?
    let alternativeName: String?
    let group: Group
    let branch: Branch
    let nationalId: String?
    let assets: Assets
    let types: [Kind]
    let capabilities: Capabilities

    // TODO: bring this back when PASTA-945 gets resolved
    // let supportedCurrencies: [String]
}

extension InstitutionResponse {
    struct Group: Codable {
        let name: String?
        let localName: String?
    }

    struct Branch: Codable {
        let name: String?
        let localName: String?
    }

    struct Assets: Codable {
        let icon: String
        let logo: String
    }

    enum Kind: String, Codable {
        case business = "BUSINESS"
        case personal = "PERSONAL"
    }

    struct Capabilities: Codable {
        let payments: Payments
    }

    struct Payments: Codable {
        let active: Bool
        let accountIdentifiersRequired: [AccountIdentifier]
        let additionalDataRequired: [AdditionalData]
        let communication: Communication
    }

    enum AccountIdentifier: String, Codable {
        case IBAN = "IBAN"
        case branchCode = "BRANCH_CODE"
        case accountNumber = "ACCOUNT_NUMBER"
        case PSUId = "PSU_ID"
    }

    enum AdditionalData: String, Codable {
        case redirectType = "REDIRECT_TYPE"
    }

    struct Communication: Codable {
        let appToApp: AppToApp
    }

    enum AppToApp: String, Codable {
        case supported = "SUPPORTED"
        case notSupported = "NOT_SUPPORTED"
        case unknown = "UNKNOWN"
    }
}
