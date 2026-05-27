//
// VoltColor.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 20/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

enum VoltColor {
    enum Namespace: String {
        case translucent = "10-Translucent",
             hint = "25-Hint",
             soft = "50-Soft",
             light = "75-Light",
             hazy = "100-Hazy",
             faint = "200-Faint",
             muted = "300-Muted",
             balanced = "400-Balanced",
             main = "500-Main",
             rich = "600-Rich",
             deep = "700-Deep",
             bold = "800-Bold",
             dark = "900-Dark",
             status = "Status"
    }

    enum Name: String {
        case blue,
             red,
             navy,
             orange,
             green,
             steel,
             grey
        case failure,
             processing,
             success
    }
}
