// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "boxpay_ios_checkout_sdk",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BoxPayiOSCheckoutSDK",
            targets: ["BoxPayiOSCheckoutSDK"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "CrossPlatformSDK",
            url: "https://github.com/BoxPay-SDKs/cross-platform-sdk/releases/download/1.0.2-beta7/cross_platform_sdk.xcframework.zip",
            checksum: "fd3601fe187df9b26a1f87a94fc8356ced022e6c30a1873a9f86fafa08f7f9f5"
        ),
        .target(
            name: "BoxPayiOSCheckoutSDK",
            dependencies: [
                "CrossPlatformSDK",
            ],
            path: "Sources/iosCheckoutSdk"
        ),

    ]
)
