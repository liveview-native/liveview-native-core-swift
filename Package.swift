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
        .binaryTarget(name: "liveview_native_core", url: "https://github.com/liveview-native/liveview-native-core/releases/download/0.1.0-7500ce9/liveview_native_core.xcframework.zip", checksum: "86aec3fd254ca2bb339bb4065cf4b989745df7ff17f2600d0d36e97a46d7193c"),
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
