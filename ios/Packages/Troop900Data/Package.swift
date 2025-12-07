// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Troop900Data",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Troop900Data",
            targets: ["Troop900Data"]
        ),
    ],
    dependencies: [
        // Local packages
        .package(path: "../Troop900Domain"),
        .package(path: "../Troop900Application"),
        // Firebase iOS SDK for Auth, Firestore, Functions
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: "12.0.0"
        ),
        // Swift Testing for tests
        .package(
            url: "https://github.com/apple/swift-testing.git",
            from: "0.10.0"
        )
    ],
    targets: [
        .target(
            name: "Troop900Data",
            dependencies: [
                "Troop900Domain",
                "Troop900Application",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk")
            ],
            path: "Sources/Troop900Data"
        ),
        .testTarget(
            name: "Troop900DataTests",
            dependencies: [
                "Troop900Data",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/Troop900DataTests"
        ),
    ]
)
