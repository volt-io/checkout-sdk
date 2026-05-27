//
// AsyncSVGImage.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 23/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

import SVGView
import SwiftUI

struct AsyncSVGImage<Loading, Failed>: View where Loading: View, Failed: View {
    enum Status {
        case loading, failed, succeeded
    }

    @StateObject private var dataProvider: CachedDataProvider
    @State private var status: Status = .loading

    private let loadingView: () -> Loading
    private let failedView: () -> Failed

    init(
        url: URL?,
        @ViewBuilder loading: @escaping () -> Loading,
        @ViewBuilder failed: @escaping () -> Failed
    ) {
        self._dataProvider = StateObject(wrappedValue: CachedDataProvider(url: url))
        self.loadingView = loading
        self.failedView = failed
    }

    var body: some View {
        VStack {
            SVGView(data: dataProvider.data ?? Data())
        }
        .overlay {
            loadingView()
                .opacity(status == .loading ? 1 : 0)
                .disabled(status != .loading)
        }
        .overlay {
            failedView()
                .opacity(status == .failed ? 1 : 0)
                .disabled(status != .failed)
        }
        .task { [dataProvider] in
            do {
                try await dataProvider.loadData()
                status = .succeeded
            } catch {
                status = .failed
            }
        }
    }
}
