// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PowninAssistant",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "PowninAssistant",
            targets: ["PowninAssistant"]
        )
    ],
    dependencies: [
        // No external dependencies - keeping it minimal
    ],
    targets: [
        .executableTarget(
            name: "PowninAssistant",
            dependencies: [],
            path: "PowninAssistant",
            exclude: ["Info.plist", "Assets.xcassets"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-concurrency"]),
            ]
        )
    ]
)
