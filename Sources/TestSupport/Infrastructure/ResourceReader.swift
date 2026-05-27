//
// ResourceReader.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 07/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

package struct ResourceReader {
    package static func read(_ name: String, withExtension ext: String? = nil) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: ext) else {
            throw URLError(.fileDoesNotExist)
        }
        return try Data(contentsOf: url)
    }

    package static func read(_ name: String, withExtension ext: String? = nil) throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: ext) else {
            throw URLError(.fileDoesNotExist)
        }
        return try String(contentsOf: url)
    }

    package static func readJSON<T>(_ name: String, to _: T.Type) throws -> T where T: Decodable {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
