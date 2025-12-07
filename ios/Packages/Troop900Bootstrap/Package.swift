// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900Bootstrap",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Troop900Bootstrap",
            targets: ["Troop900Bootstrap"]
        ),
    ],
    dependencies: [
        // Local data package (for dependency injection / wiring)
        .package(path: "../Troop900Data"),
        // Firebase Core for configuring FirebaseApp
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.0.0"
        )
    ],
    targets: [
        .target(
            name: "Troop900Bootstrap",
            dependencies: [
                "Troop900Data",
                .product(name: "FirebaseCore", package: "firebase-ios-sdk")
            ],
            path: "Sources/Troop900Bootstrap"
        ),
        .testTarget(
            name: "Troop900BootstrapTests",
            dependencies: [
                "Troop900Bootstrap"
            ],
            path: "Tests/Troop900BootstrapTests"
        ),
    ]
)


