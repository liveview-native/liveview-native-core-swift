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
        .binaryTarget(name: "liveview_native_core", url: "https://github.com/liveviewnative/liveview-native-core/releases/download/0.1.0-d5b36bc/liveview_native_core.xcframework.zip", checksum: "4fdbed1e0a750ae95bcd7b6bd7dc3af500dba3d9012313503ef8804de2a4d741"),
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
