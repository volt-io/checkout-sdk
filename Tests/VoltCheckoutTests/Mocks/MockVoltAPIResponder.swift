//
// MockVoltAPIResponder.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport

enum MockVoltAPIResponder {
    case getInstitutionsCountries, getInstitutions, getInstitution,
         createPayment, getPayment, cancelPayment, errorForbidden

    var session: URLSession {
        switch self {
        case .getInstitutionsCountries:
            URLSession(mockResponder: GetInstitutionsCountries.self)
        case .getInstitutions:
            URLSession(mockResponder: GetInstitutions.self)
        case .getInstitution:
            URLSession(mockResponder: GetInstitution.self)
        case .createPayment:
            URLSession(mockResponder: CreatePayment.self)
        case .getPayment:
            URLSession(mockResponder: GetPayment.self)
        case .cancelPayment:
            URLSession(mockResponder: CancelPayment.self)
        case .errorForbidden:
            URLSession(mockResponder: ErrorForbidden.self)
        }
    }

    struct GetInstitutionsCountries: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (try ResourceReader.read("InstitutionsCountries", withExtension: "json"),
             HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
             ))
        }
    }

    struct GetInstitutions: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (try ResourceReader.read("InstitutionsListDE", withExtension: "json"),
             HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
             ))
        }
    }

    struct GetInstitution: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (try ResourceReader.read("InstitutionResponse", withExtension: "json"),
             HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
        }
    }

    struct CreatePayment: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (try ResourceReader.read("PaymentResponse-1", withExtension: "json"),
             HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
        }
    }

    struct GetPayment: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (try ResourceReader.read("PaymentResponse-2", withExtension: "json"),
             HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
        }
    }

    struct CancelPayment: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (Data(), HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
        }
    }

    struct ErrorForbidden: MockURLResponder {
        static func respond(to request: URLRequest) throws -> (Data?, HTTPURLResponse?) {
            (#"{"code":"ACCESS_DENIED","message":"Access denied."}"#.data(using: .utf8),
             HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 403,
                httpVersion: nil,
                headerFields: nil
             ))
        }
    }
}
