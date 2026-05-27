// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DevPorts",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "DevPorts",
            path: "Sources/DevPorts",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        )
    ]
)
