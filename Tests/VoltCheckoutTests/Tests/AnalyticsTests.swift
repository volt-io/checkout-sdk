//
// AnalyticsTests.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 06/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import Testing
import TestSupport
import HTTPNetworking
@testable @_spi(TestTarget) import VoltCheckout

@Suite("Analytics module tests")
@MainActor struct AnalyticsTests {
    static let integrationType = "mobileiOSSDK"
    static let customerId = "1234567890"
    static let endpointPath = "/track"
    static let config = VoltCheckout.Configuration<VoltAPISandboxHost>(customerId: customerId) { "fake_auth_token" }

    let logReader: LogReader
    let successSession: URLSession
    let failureSession: URLSession
    let testEventId: String
    let testEvent: Event

    init() {
        self.logReader = try! LogReader(subsystem: VoltCheckout.identifier, category: "Analytics")
        self.successSession = URLSession(mockResponder: MockEventResponder.Success.self)
        self.failureSession = URLSession(mockResponder: MockEventResponder.Failure.self)
        self.testEventId = UUID().uuidString
        self.testEvent = Event(name: .bankChange, properties: [
            .customerId: Self.customerId,
            .insertId: self.testEventId
        ])
    }

    @Test("When inspecting DeviceInfo properties, then they match given patterns")
    func testDeviceInfo() async throws {
        let modelRegex = /^iP.*\(Model arm64\)$/
        let systemRegex = /^iOS, Version \S* \(Build \w+\)$/

        #expect(!DeviceInfo.identifier.isEmpty)
        #expect(DeviceInfo.model.wholeMatch(of: modelRegex) != nil)
        #expect(DeviceInfo.system.wholeMatch(of: systemRegex) != nil)
    }

    @Test("When inspecting trackEvent endpoint, then it has correct method, path and host")
    func testTrackEndpoint() async throws {
        let endpoint = HTTPEndpoint.trackEvent

        #expect(endpoint.method == .post)
        #expect(endpoint.path == Self.endpointPath)
        #expect(try endpoint.url.host() == AnalyticsService.Host.authority)
    }

    @Test("When tracking analytics event, then it is sent without throwing any errors")
    func testAnalyticsServiceSending() async throws {
        let service = AnalyticsService(session: successSession)

        await #expect(throws: Never.self, performing: {
            try await service.send(testEvent)
        })
    }

    @Test("When sending analytics event fails, then correct error is thrown")
    func testAnalyticsServiceErrorHandling() async throws {
        let service = AnalyticsService(session: failureSession)

        await #expect(throws: APIClientError.invalidResponse(.internalServerError), performing: {
            try await service.send(testEvent)
        })
    }

    @Test("When inspecting tracker configuration, then it contains correct values for default properties")
    func testConfigurationDefaultProperties() async throws {
        let config = EventTracker.Configuration.mixpanel([.token: "alternative-token"])
        let tracker = EventTracker(service: AnalyticsService(session: successSession), configuration: config)
        let properties = tracker.combinedProperties

        #expect(properties[.SDKVersion] == VoltCheckout.Version.current.value)
        #expect(properties[.integrationType] == Self.integrationType)
        #expect(properties[.token] == "alternative-token")
    }

    @Test("When tracking events with one tracker, then dynamic properties should be different for each event", .disabled())
    func testEventTrackerEventProperties() async throws {
        let tracker = EventTracker(service: AnalyticsService(session: successSession), configuration: .mixpanel([:]))

        tracker.track(testEvent.name, testEvent.properties)
        let eventLog1 = try logReader.logs.last!
        tracker.track(testEvent.name, testEvent.properties)
        let eventLog2 = try logReader.logs.last!
        
        #expect(eventLog1.composedMessage != eventLog2.composedMessage)
    }

    @Test("When tracking analytics event, then it should be logged in DEBUG configuration", .disabled())
    func testEventTrackerLogging() async throws {
        let tracker = EventTracker(service: AnalyticsService(session: successSession), configuration: .mixpanel([:]))

        tracker.track(testEvent.name, testEvent.properties)
        #expect(try logReader.logs.last!.composedMessage.contains(testEventId))
    }

    @Test("When tracking analytics event, then custom properties should override default ones", .disabled())
    func testEventTrackingProperties() async throws {
        let tracker = EventTracker(service: AnalyticsService(session: successSession), configuration: .mixpanel([:]))
        let expectedId = UUID().uuidString

        tracker.track(testEvent.name, [.insertId: expectedId])
        #expect(try logReader.logs.last!.composedMessage.contains(expectedId))
    }
}
