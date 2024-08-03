// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Carbon",
    platforms: [.macOS(.v14),
                .iOS(.v16),
                .tvOS(.v16),
                .watchOS(.v8)
    ],
    products: [
        // Products visible to other packages.
        .library(
            name: "Carbon",
            targets: [
                "AnyCodable",
                "Carbon",
            ]),
    ],
    targets: [
        .target(
            name: "Carbon",
            dependencies: [
                "AnyCodable",
            ]
        ),
        .target(
            name: "AnyCodable"),
        .testTarget(
            name: "CarbonTests",
            dependencies: ["Carbon"]
        ),
    ]
)
