// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LiveViewNativeCore",
    products: [
        .library(
            name: "LiveViewNativeCore",
            targets: ["LiveViewNativeCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .binaryTarget(name: "liveview_native_core", url: "https://github.com/liveviewnative/liveview-native-core/releases/download/0.1.0-37d7970/liveview_native_core.xcframework.zip", checksum: "8871a26c356b2ebd6554903d345a95823d384c030f95f49d57dcad1b70b4cfd0"),
        //.binaryTarget(name: "liveview_native_core", path: "liveview_native_core.xcframework"),
        .target(
            name: "LiveViewNativeCore",
            dependencies: [
                .target(name: "liveview_native_core")
            ]),
        .testTarget(
            name: "LiveViewNativeCoreTests",
            dependencies: ["LiveViewNativeCore"]),
    ]
)
