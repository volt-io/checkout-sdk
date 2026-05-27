//
// Data+HTTPNetworking.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 09/12/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyJSON = String(data: data, encoding: .utf8) else {
            return nil
        }
        return prettyJSON
    }
}
