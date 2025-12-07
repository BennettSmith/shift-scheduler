// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900Application",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Troop900Application",
            targets: ["Troop900Application"]
        ),
    ],
    dependencies: [
        // Local domain package
        .package(path: "../Troop900Domain"),
        // Swift Testing for tests
        .package(
            url: "https://github.com/apple/swift-testing.git",
            from: "0.10.0"
        )
    ],
    targets: [
        .target(
            name: "Troop900Application",
            dependencies: [
                "Troop900Domain"
            ],
            path: "Sources/Troop900Application"
        ),
        .testTarget(
            name: "Troop900ApplicationTests",
            dependencies: [
                "Troop900Application",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/Troop900ApplicationTests"
        ),
    ]
)

