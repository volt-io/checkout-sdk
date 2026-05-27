//
// AccountIdentifiersData.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 16/03/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct AccountIdentifiersData: Equatable, Hashable {
    var IBAN: IBAN?
    var branchCode: BranchCode?
    var accountNumber: AccountNumber?
    var PSUId: PSUId?
}

extension AccountIdentifiersData {
    var requiredIdentifiers: [AccountIdentifier] {
        AccountIdentifier.allCases.filter {
            switch $0 {
            case .IBAN: IBAN != nil
            case .branchCode: branchCode != nil
            case .accountNumber: accountNumber != nil
            case .PSUId: PSUId != nil
            }
        }
    }
}

extension AccountIdentifiersData {
    init(_ accountIdentifiers: Set<AccountIdentifier>, countryCode: Locale.Region) {
        for accountIdentifier in accountIdentifiers {
            switch accountIdentifier {
            case .IBAN:
                self.IBAN = ""
            case .branchCode:
                self.branchCode = ""
            case .accountNumber:
                self.accountNumber = .init(countryCode: countryCode, number: "")
            case .PSUId:
                self.PSUId = ""
            }
        }
    }
}
