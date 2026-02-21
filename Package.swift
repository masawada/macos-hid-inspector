// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "macos-hid-inspector",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "inspect-hid", targets: ["InspectHID"]),
        .library(name: "InspectHIDCore", targets: ["InspectHIDCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.0"),
    ],
    targets: [
        .executableTarget(
            name: "InspectHID",
            dependencies: [
                "InspectHIDCore"
            ]
        ),
        .target(
            name: "InspectHIDCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "InspectHIDCoreTests",
            dependencies: [
                "InspectHIDCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
