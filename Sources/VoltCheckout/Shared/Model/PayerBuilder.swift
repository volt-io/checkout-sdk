//
// PayerBuilder.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 14/05/2026.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

/// Collects ``Payer/Person`` and ``Payer/Organization`` components and resolves them to a ``Payer/Entity``.
///
/// Use via the ``Payer/init(reference:email:phone:entity:)`` convenience initializer:
/// ```swift
/// Payer(reference: "john@example.com") {
///     Payer.Person(firstName: "John", lastName: "Doe")
/// }
///
/// Payer(reference: "acme-corp", email: "billing@acme.com") {
///     Payer.Organization(name: "Acme Corp")
/// }
///
/// Payer(reference: "john@acme.com") {
///     Payer.Person(firstName: "John", lastName: "Doe")
///     Payer.Organization(name: "Acme Corp")
/// }
/// ```
@resultBuilder
public enum PayerEntityBuilder {
    /// Provides contextual type information to translate `Payer.Person` into partial result.
    public static func buildExpression(_ person: Payer.Person) -> Component { .person(person) }

    /// Provides contextual type information to translate `Payer.Person?` into partial result.
    public static func buildExpression(_ person: Payer.Person?) -> Component {
        person.map { .person($0) } ?? .missing
    }

    /// Provides contextual type information to translate `Payer.Organization` into partial result.
    public static func buildExpression(_ org: Payer.Organization) -> Component { .organization(org) }

    /// Provides contextual type information to translate `Payer.Organization?` into partial result.
    public static func buildExpression(_ org: Payer.Organization?) -> Component {
        org.map { .organization($0) } ?? .missing
    }

    /// Builds combined results from statement blocks.
    public static func buildBlock(_ components: Component...) -> Payer.Entity? {
        var person: Payer.Person?
        var org: Payer.Organization?

        for component in components {
            switch component {
            case .person(let value):
                person = value
            case .organization(let value):
                org = value
            case .missing:
                return nil
            }
        }

        switch (person, org) {
        case let (person?, org?):
            return .both(person, org)
        case let (person?, nil):
            return .person(person)
        case let (nil, org?):
            return .organization(org)
        case (nil, nil):
            return nil
        }
    }

    /// The type of a partial result, which will be carried through all of the build functions.
    public enum Component: Sendable {
        case person(Payer.Person)
        case organization(Payer.Organization)
        case missing
    }
}

extension Payer {
    /// Creates a ``Payer`` using a raw reference string and a declarative entity builder.
    ///
    /// Returns `nil` if the reference string fails validation or if the entity closure
    /// produces no valid entity (e.g. because a failable initializer returned `nil`).
    /// - Parameters:
    ///   - reference: Your unique reference for the payer, e.g. customer ID or email address.
    ///   - email: Payer email address.
    ///   - phone: Phone number, in E.164 format.
    ///   - entity: A builder closure providing the payer entity.
    public init?(
        reference: String,
        email: String? = nil,
        phone: String? = nil,
        @PayerEntityBuilder entity: () -> Payer.Entity?
    ) {
        guard let ref = Payer.Reference(reference), let resolvedEntity = entity() else { return nil }
        self.init(reference: ref, entity: resolvedEntity, email: email, phone: phone)
    }
}
