// swift-tools-version: 6.0
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
            ],
            path: "Tests/Troop900ApplicationTests"
        ),
    ]
)

