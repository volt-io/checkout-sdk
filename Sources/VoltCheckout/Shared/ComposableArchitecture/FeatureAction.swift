//
// FeatureAction.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 15/01/2026.
// Copyright © 2026 Volt Technologies Holdings Ltd. All rights reserved.
//

import ComposableArchitecture
import Foundation

protocol FeatureAction {
    associatedtype ViewAction
    associatedtype DelegateAction
    associatedtype InternalAction

    static func view(_: ViewAction) -> Self
    static func delegate(_: DelegateAction) -> Self
    static func _internal(_: InternalAction) -> Self
}
