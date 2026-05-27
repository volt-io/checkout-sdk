//
// PaymentIntentBuilder.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/05/2026.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

/// Collects ``PaymentIntent`` components declared in a builder closure.
///
/// Use via the ``PaymentIntent/init(_:)`` convenience initializer:
/// ```swift
/// let intent = PaymentIntent {
///     Amount(currency: .EUR, minorUnits: 100)
///     Payer(reference: "john@example.com") {
///         Payer.Person(firstName: "John", lastName: "Doe")
///     }
///     TransactionType.goods
///     PaymentReferences(paymentReference: "REF123")
/// }
/// ```
@resultBuilder
public enum PaymentIntentBuilder {
    /// Provides contextual type information to translate `Amount` into partial result.
    public static func buildExpression(_ amount: Amount) -> Component { .amount(amount) }

    /// Provides contextual type information to translate `Amount?` into partial result.
    public static func buildExpression(_ amount: Amount?) -> Component { amount.map { .amount($0) } ?? .missing }

    /// Provides contextual type information to translate `Payer` into partial result.
    public static func buildExpression(_ payer: Payer) -> Component { .payer(payer) }

    /// Provides contextual type information to translate `Payer?` into partial result.
    public static func buildExpression(_ payer: Payer?) -> Component { payer.map { .payer($0) } ?? .missing }

    /// Provides contextual type information to translate `TransactionType` into partial result.
    public static func buildExpression(_ transactionType: TransactionType) -> Component {
        .transactionType(transactionType)
    }

    /// Provides contextual type information to translate `PaymentReferences` into partial result.
    public static func buildExpression(_ references: PaymentReferences) -> Component { .references(references) }

    /// Provides contextual type information to translate `PaymentReferences?` into partial result.
    public static func buildExpression(_ references: PaymentReferences?) -> Component {
        references.map { .references($0) } ?? .missing
    }

    /// Builds combined results from statement blocks.
    public static func buildBlock(_ components: Component...) -> [Component] { components }

    /// The type of a partial result, which will be carried through all of the build functions.
    public enum Component: Sendable {
        case amount(Amount)
        case payer(Payer)
        case transactionType(TransactionType)
        case references(PaymentReferences)
        case missing
    }
}

extension PaymentIntent {
    /// Creates a ``PaymentIntent`` using a declarative builder syntax.
    ///
    /// Returns `nil` if any required component (`Amount`, `Payer`, `TransactionType`) is missing
    /// or if any component's own failable initializer produced `nil`.
    public init?(@PaymentIntentBuilder _ build: () -> [PaymentIntentBuilder.Component]) {
        var amount: Amount?
        var payer: Payer?
        var transactionType: TransactionType?
        var references: PaymentReferences?

        for component in build() {
            switch component {
            case .amount(let value):
                amount = value
            case .payer(let value):
                payer = value
            case .transactionType(let value):
                transactionType = value
            case .references(let value):
                references = value
            case .missing:
                return nil
            }
        }

        guard let amount, let payer, let transactionType else { return nil }
        self.init(amount: amount, payer: payer, transactionType: transactionType, references: references)
    }
}
