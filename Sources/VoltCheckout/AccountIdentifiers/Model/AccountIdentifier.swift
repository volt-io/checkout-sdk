//
// AccountIdentifier.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 13/01/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

enum AccountIdentifier: Equatable, CaseIterable {
    case IBAN, branchCode, accountNumber, PSUId
}

extension AccountIdentifier {
    init(with responseIdentifier: InstitutionResponse.AccountIdentifier) {
        switch responseIdentifier {
        case .IBAN:
            self = .IBAN
        case .branchCode:
            self = .branchCode
        case .accountNumber:
            self = .accountNumber
        case .PSUId:
            self = .PSUId
        }
    }
}
