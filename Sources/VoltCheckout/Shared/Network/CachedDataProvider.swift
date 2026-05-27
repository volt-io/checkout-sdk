//
// CachedDataProvider.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 26/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

class CachedDataProvider: ObservableObject {
    static let session: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024, // 10MB memory cache
            diskCapacity: 50 * 1024 * 1024 // 50MB disk cache
        )
        return URLSession(configuration: configuration)
    }()

    @Published private(set) var data: Data?

    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    @MainActor
    func loadData() async throws {
        guard let url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await Self.session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        self.data = data
    }

    func removeCachedResponse() {
        guard let url else { return }
        let request = URLRequest(url: url)
        Self.session.configuration.urlCache?.removeCachedResponse(for: request)
    }

    static func clearCache() {
        session.configuration.urlCache?.removeAllCachedResponses()
    }
}
