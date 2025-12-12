// swift-tools-version: 6.0
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
        // Local packages
        .package(path: "../Troop900Domain"),
        .package(path: "../Troop900Application")
    ],
    targets: [
        .target(
            name: "Troop900Presentation",
            dependencies: [
                "Troop900Domain",
                "Troop900Application"
            ],
            path: "Sources/Troop900Presentation"
        ),
        .testTarget(
            name: "Troop900PresentationTests",
            dependencies: [
                "Troop900Presentation"
            ],
            path: "Tests/Troop900PresentationTests"
        ),
    ]
)
