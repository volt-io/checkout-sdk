// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VoltCheckout",
    platforms: [
        .iOS("16.4"),
    ],
    products: [
        .library(
            name: "VoltCheckout",
            targets: ["VoltCheckout"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/exyte/SVGView.git", from: "1.0.6"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.20.0"),
    ],
    targets: [
        .target(
            name: "VoltCheckout",
            dependencies: [
                .target(name: "VoltDesignSystem"),
                .target(name: "HTTPNetworking"),
                .target(name: "SwiftUIValidation"),
                .target(name: "TestSupport"),
                .product(name: "SVGView", package: "SVGView"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [.process("Resources")],
            swiftSettings: [
                .define("ENABLE_ANALYTICS", .when(configuration: .release)),
                .enableUpcomingFeature("InternalImportsByDefault"),
            ],
        ),
        .target(
            name: "VoltDesignSystem",
            dependencies: ["SwiftUIValidation"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "HTTPNetworking",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
            ]
        ),
        .target(
            name: "SwiftUIValidation"
        ),

        // Test support
        .target(
            name: "TestSupport",
            dependencies: ["HTTPNetworking"],
            resources: [.process("Resources")]
        ),

        // Tests
        .testTarget(
            name: "HTTPNetworkingTests",
            dependencies: ["HTTPNetworking", "TestSupport"]
        ),
        .testTarget(
            name: "VoltCheckoutTests",
            dependencies: ["VoltCheckout", "TestSupport"]
        ),
    ]
)
