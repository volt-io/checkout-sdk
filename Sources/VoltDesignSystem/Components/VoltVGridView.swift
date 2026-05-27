//
// VoltVGridView.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 24/09/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SwiftUI

package struct VoltVGridView<Content: View, Footer: View>: View {
    package let content: Content
    package let footer: Footer

    @ScaledMetric private var itemMinWidth: CGFloat = 85.0
    @ScaledMetric private var itemSpacing: CGFloat = .voltSpacing2

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: itemMinWidth), spacing: itemSpacing, alignment: .top)]
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: itemSpacing) {
            content
        }
        .padding(.horizontal, .voltPadding5)
    }

    package var body: some View {
        ViewThatFits(in: .vertical) {
            VStack(spacing: 0.0) {
                grid
                Spacer()
                footer
            }
            ScrollView {
                grid
                footer
            }
        }
    }
}

extension VoltVGridView {
    package init(@ViewBuilder _ content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.content = content()
        self.footer = footer()
    }
}

extension VoltVGridView where Footer == EmptyView {
    package init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
        self.footer = EmptyView()
    }
}
