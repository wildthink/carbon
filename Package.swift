// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let includeMacros = false
let includeDebugTarget = true

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
                "Carbon",
            ]),
        .library(
            name: "FSEvents",
            targets: [
                "FSEvents",
            ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "Carbon",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "FSEvents",
            dependencies: [
                "Carbon",
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "CarbonTests",
            dependencies: ["Carbon"]
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
