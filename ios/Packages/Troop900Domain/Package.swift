// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900Domain",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Troop900Domain",
            targets: ["Troop900Domain"]
        ),
    ],
    dependencies: [
        // Domain has no runtime dependencies, but tests use the Swift Testing package.
        .package(
            url: "https://github.com/apple/swift-testing.git",
            from: "0.10.0"
        )
    ],
    targets: [
        .target(
            name: "Troop900Domain",
            dependencies: [],
            path: "Sources/Troop900Domain"
        ),
        .testTarget(
            name: "Troop900DomainTests",
            dependencies: [
                "Troop900Domain",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/Troop900DomainTests"
        ),
    ]
)


