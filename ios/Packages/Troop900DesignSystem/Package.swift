// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900DesignSystem",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Troop900DesignSystem",
            targets: ["Troop900DesignSystem"]
        ),
    ],
    dependencies: [
        // Swift Testing for tests
        .package(
            url: "https://github.com/apple/swift-testing.git",
            from: "0.10.0"
        )
    ],
    targets: [
        .target(
            name: "Troop900DesignSystem",
            dependencies: [],
            path: "Sources/Troop900DesignSystem",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "Troop900DesignSystemTests",
            dependencies: [
                "Troop900DesignSystem",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/Troop900DesignSystemTests"
        ),
    ]
)
