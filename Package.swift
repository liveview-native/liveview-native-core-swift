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
        .binaryTarget(name: "liveview_native_core", url: "https://github.com/liveviewnative/liveview-native-core/releases/download/0.1.0-026f5d1/liveview_native_core.xcframework.zip", checksum: "f7e29069e2d672f8abb21dad3564d4592552420fdf26422cf6a7748509b8ebd5"),
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
