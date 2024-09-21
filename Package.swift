// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let includeMacros = false
let includeDebugTarget = true

let package = Package(
    name: "Carbon14",
    platforms: [.macOS(.v14),
                .iOS(.v16),
                .tvOS(.v16),
                .watchOS(.v8)
    ],
    products: [
        // Products visible to other packages.
        .library(
            name: "Carbon14",
            targets: [
                "Carbon14",
            ]),
        .library(
            name: "Carbon14UX",
            targets: [
                "Carbon14UX",
            ]),
        .library(
            name: "CarbonLabs",
            targets: [
               "Carbon14",
               "CarbonLabs",
            ]),
        .library(
            name: "FSEvents",
            targets: [
                "FSEvents",
            ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-issue-reporting.git", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "Carbon14",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "IssueReporting", package: "swift-issue-reporting"),
            ]
        ),
        .target(
            name: "Carbon14UX",
            dependencies: [
                "Carbon14",
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "CarbonLabs",
            dependencies: [
                "Carbon14",
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "FSEvents",
            dependencies: [
                "Carbon14",
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "CarbonTests",
            dependencies: ["Carbon14"]
        ),
    ]
)

//if includeDebugTarget == true {
//    package.targets.append(
//        .executableTarget(name: "debug",
//                          dependencies: [
//                          ],
//                          swiftSettings: [
//                            .unsafeFlags(["-enable-bare-slash-regex"])
//                          ])
//    )
//    
//    package.products.append(
//        .executable(name: "debug", targets: ["debug"])
//    )
//}
