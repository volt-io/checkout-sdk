//
// InstitutionGroupLabelView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 13/08/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

struct InstitutionGroupLabelView: View {
    let group: Institution.Group
    let displayMode: InstitutionGroupPresentation.DisplayMode

    private var displayName: String {
        guard group.branches.count == 1 else {
            return "\(group.name) (\(group.branches.count))"
        }
        if case .list = displayMode, let branch = group.branches.first {
            let branchName = branch.branchName ?? branch.name
            if group.name != branchName {
                return "\(group.name) > \(branchName)"
            }
        }
        return group.name
    }
    private var iconOpacity: Double {
        !group.isActive && group.branches.count == 1 ? 0.6 : 1.0
    }
    private var textColor: Color {
        !group.isActive ? .voltFaintSteelColor : .voltMainSteelColor
    }

    var body: some View {
        Label {
            Text(displayName)
        } icon: {
            AsyncSVGImage(url: group.logo) {
                ProgressView()
            } failed: {
                Image.voltBankIcon
                    .voltPlaceholderImageStyle()
            }
            .opacity(iconOpacity)
            .background(Color.voltHintSteelColor)
            .cornerRadius(.voltRadius3)
        }
        .modifier(InstitutionGroupPresentation(displayMode: displayMode))
        .tint(textColor)
    }
}

struct InstitutionGroupPresentation: ViewModifier {
    enum DisplayMode {
        case grid, list
    }

    let displayMode: DisplayMode

    func body(content: Content) -> some View {
        switch displayMode {
        case .grid:
            content.labelStyle(.voltGrid)
        case .list:
            content.labelStyle(.voltList)
        }
    }
}
