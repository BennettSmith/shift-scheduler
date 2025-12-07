// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900Presentation",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Troop900Presentation",
            targets: ["Troop900Presentation"]
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
            name: "Troop900Presentation",
            dependencies: [
                "Troop900Domain"
            ],
            path: "Sources/Troop900Presentation"
        ),
        .testTarget(
            name: "Troop900PresentationTests",
            dependencies: [
                "Troop900Presentation",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/Troop900PresentationTests"
        ),
    ]
)


