//
// VoltCheckout+Configuration.swift
// VoltCheckout
//
// Created by Maciej Sienkiewicz on 05/05/2025.
// Copyright © 2025 Volt Technologies Holdings Ltd. All rights reserved.
//

extension VoltCheckout {
    /// Authentication token provider handler. See `VoltCheckout.Configuration.tokenProvider` for more info.
    public typealias AuthTokenProvider = @Sendable () async throws -> String

    /// Parameters that are used to configure the SDK at the initialization.
    ///
    /// Create your custom configuration and use it to initialize the SDK.
    /// Each configuration is specialized with `Host` type, that defines backend that SDK connects to.
    /// Use `VoltAPIProductionHost` for production builds distributed to end users.
    /// Use `VoltAPISandboxHost` to test SDK integration. When using sandbox host no real money change hands.
    public struct Configuration<Host>: Sendable where Host: VoltAPIHost {
        /// Merchant identifier in Volt Fuzebox system.
        public let customerId: String
        
        /// A callback that returns valid access token that SDK will use to authorize requests to Volt API.
        ///
        /// In your app implement authorization according to
        /// [Volt Global API docs](https://docs.volt.io/global-payments-api-documentation).
        /// Make sure to include the `scope` parameter with value `mobile` in the oAuth request body,
        /// to limit the scope of the access token. Pass a function or method that returns the access token
        /// to the SDK as a `tokenProvider`. This handler will be called just before each request that
        /// SDK makes to the Volt API. It's up to you to implement token caching and refreshing.
        public let tokenProvider: AuthTokenProvider

        @_spi(TestTarget)
        public init(customerId: String, tokenProvider: @escaping AuthTokenProvider) {
            self.customerId = customerId
            self.tokenProvider = tokenProvider
        }
    }
}

extension VoltCheckout.Configuration where Host == VoltAPISandboxHost {
    /// Convenience static method for creating checkout configuration that connects to sandbox environment.
    /// - Parameters:
    ///   - customerId: See documentation for `VoltCheckout.Configuration.customerId`.
    ///   - tokenProvider: See documentation for `VoltCheckout.Configuration.tokenProvider`.
    /// - Returns: Configuration specialized with `VoltAPISandboxHost`.
    public static func sandbox(
        customerId: String,
        tokenProvider: @escaping VoltCheckout.AuthTokenProvider
    ) -> Self {
        .init(customerId: customerId, tokenProvider: tokenProvider)
    }
}

extension VoltCheckout.Configuration where Host == VoltAPIProductionHost {
    /// Convenience static method for creating checkout configuration that connects to production environment.
    /// - Parameters:
    ///   - customerId: See documentation for `VoltCheckout.Configuration.customerId`.
    ///   - tokenProvider: See documentation for `VoltCheckout.Configuration.tokenProvider`.
    /// - Returns: Configuration specialized with `VoltAPIProductionHost`.
    public static func production(
        customerId: String,
        tokenProvider: @escaping VoltCheckout.AuthTokenProvider
    ) -> Self {
        .init(customerId: customerId, tokenProvider: tokenProvider)
    }
}
