// swift-tools-version: 6.0
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
    dependencies: [],
    targets: [
        .target(
            name: "Troop900Domain",
            dependencies: [],
            path: "Sources/Troop900Domain"
        ),
        .testTarget(
            name: "Troop900DomainTests",
            dependencies: [
                "Troop900Domain"
            ],
            path: "Tests/Troop900DomainTests"
        ),
    ]
)
