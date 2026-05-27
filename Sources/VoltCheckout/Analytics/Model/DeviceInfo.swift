//
// DeviceInfo.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 28/04/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import Foundation
import UIKit.UIDevice

/// Provides basic information about the device and system
@MainActor
struct DeviceInfo {
    /// A device identifier managed according to `UIDevice.identifierForVendor`.
    static let identifier = device.identifierForVendor?.uuidString ?? ""

    /// A device model string containing device type as well as hardware model.
    static let model = "\(device.model) (Model \(machineModel))"

    /// System name and version string.
    static let system = "\(device.systemName), \(procInfo.operatingSystemVersionString)"

    private static var device: UIDevice { .current }

    private static var procInfo: ProcessInfo { .processInfo }

    private static var machineModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce(into: "") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            identifier += String(UnicodeScalar(UInt8(value)))
        }
    }
}
