//
// PaymentIntent.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/10/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

/// An intent that describes a payment to be initialized.
public struct PaymentIntent: Hashable, Equatable, Codable, Sendable {
    /// An amount of money in specific currency.
    public let amount: Amount

    /// Information about the payer.
    public let payer: Payer

    /// Transaction type.
    public let transactionType: TransactionType

    /// Additional payment references.
    public let references: PaymentReferences?
    
    /// Creates payment intent.
    /// - Parameters:
    ///   - amount: An amount of money in specific currency.
    ///   - payer: Information about the payer.
    ///   - transactionType: Transaction type.
    ///   - references: Additional payment references.
    public init(amount: Amount, payer: Payer, transactionType: TransactionType, references: PaymentReferences? = nil) {
        self.amount = amount
        self.payer = payer
        self.transactionType = transactionType
        self.references = references
    }
}
