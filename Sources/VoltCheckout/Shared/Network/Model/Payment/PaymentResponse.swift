//
// PaymentResponse.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/07/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

struct PaymentResponse: Codable {
    let id: String
    let currency: String
    let amount: Int
    let paymentReference: String
    var internalReference: String?
    let paymentSystem: PaymentSystem
    let openBankingEU: OpenBankingResponse?
    let openBankingUK: OpenBankingResponse?
    let status: PaymentStatus
    let paymentInitiationFlow: PaymentInitiationFlow
}

extension PaymentResponse {
    struct OpenBankingResponse: Codable {
        let type: PaymentType
        var institutionId: UUID?
        var validityPeriod: UInt?
        let accountIdentifiers: AccountIdentifiers
        var provider: String?
    }

    struct PaymentInitiationFlow: Codable {
        let status: PaymentInitiationStatus
        let details: PaymentInitiationDetails
        var requiredInput: [RequiredInput]?
    }

    enum PaymentInitiationStatus: String, Codable {
        case processing = "PROCESSING"
        case finished = "FINISHED"
        case aborted = "ABORTED"
        case exception = "EXCEPTION"
        case waitingForInput = "WAITING_FOR_INPUT"
    }

    struct PaymentInitiationDetails: Codable {
        let reason: PaymentInitiationReason
        var redirect: PaymentInitiationRedirect?
        let token: String?
    }

    enum PaymentInitiationReason: String, Codable {
        case awaitingUserRedirect = "AWAITING_USER_REDIRECT"
        case awaitingRedirectUrl = "AWAITING_REDIRECT_URL"
        case awaitingDecoupledAuthorization = "AWAITING_DECOUPLED_AUTHORISATION"
        case awaitingSDKHandoff = "AWAITING_SDK_HANDOFF"
    }

    struct PaymentInitiationRedirect: Codable {
        let url: String
        let directUrl: String
    }

    struct RequiredInput: Codable {
        let name: RequiredInputName
        let propertyPath: String
        var allowedValues: [AllowedValue]?
    }

    enum RequiredInputName: String, Codable {
        case IBAN = "IBAN"
        case branchCode = "BRANCH_CODE"
        case accountNumber = "ACCOUNT_NUMBER"
        case institutionId = "INSTITUTION_ID"
        case SCAUsername = "SCA_USERNAME"
        case SCAPassword = "SCA_PASSWORD"
        case redirectType = "REDIRECT_TYPE"
        case SCAMethod = "SCA_METHOD"
        case SCACode = "SCA_CODE"
        case PSUId = "PSU_ID"
    }

    struct AllowedValue: Codable {
        let name: AllowedValueName
        let value: String
        var description: String?
    }

    enum AllowedValueName: String, Codable {
        case pushOTP = "PUSH_OTP"
        case smsOTP = "SMS_OTP"
        case app = "APP"
        case web = "WEB"
    }
}
