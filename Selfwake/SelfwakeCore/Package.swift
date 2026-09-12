// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SelfwakeCore",
    platforms: [.iOS("18.0")],
    products: [
        .library(name: "SelfwakeCore", targets: ["SelfwakeCore"])
    ],
    targets: [
        .target(name: "SelfwakeCore"),
        .testTarget(name: "SelfwakeCoreTests", dependencies: ["SelfwakeCore"])
    ]
)
