// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GOLibrary",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GOLibrary",
            targets: ["GOLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.6.2"),
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.0.0"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GOLibrary",
            dependencies: [
                "Kingfisher",
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "Lottie", package: "lottie-ios")
                
            ]
        ),
        .testTarget(
            name: "GOLibraryTests",
            dependencies: ["GOLibrary"]
        ),
    ]
)
