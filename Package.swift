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
        .binaryTarget(
            name: "liveview_native_core",
            url: "https://github.com/liveview-native/liveview-native-core/releases/download/0.2.1/liveview_native_core.xcframework.zip",
            checksum: "c50172251f95b9e0dd15bf35fb094d627ba4e2d3057385395c21ec933122a344"
        ),
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
