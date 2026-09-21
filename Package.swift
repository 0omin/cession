// swift-tools-version: 6.0
import PackageDescription

// Dependencies point one way: CessionApp -> CessionGhostty -> CessionCore.
// The core never imports an adapter, so terminal quirks cannot leak into it.
let package = Package(
    name: "cession",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "CessionCore"),
        .target(name: "CessionGhostty", dependencies: ["CessionCore"]),
        .executableTarget(name: "CessionApp", dependencies: ["CessionCore", "CessionGhostty"]),
        .testTarget(name: "CessionCoreTests", dependencies: ["CessionCore"]),
    ]
)
