// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iosCheckoutSdk",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "iosCheckoutSdk",
            targets: ["iosCheckoutSdk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.5.1"),
        .package(url: "https://github.com/SVGKit/SVGKit.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "iosCheckoutSdk",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "SVGKit", package: "SVGKit")
            ],
            path: "Sources/iosCheckoutSdk",
            resources: [
                .copy("../Resources")
            ]
        ),

    ]
)
