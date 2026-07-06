// swift-tools-version: 5.10
// Binary distribution manifest for MubeenDeviceSDK.
// Ship THIS Package.swift (renamed appropriately) in the repo/URL you give
// customers — it points at the prebuilt, closed-source .xcframework.
import PackageDescription

let package = Package(
    name: "MubeenDeviceSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "MubeenDeviceSDK", targets: ["MubeenDeviceSDK"]),
    ],
    targets: [
        // Remote (recommended for customers): host the zip, paste its checksum.
        // Get both from Scripts/build-xcframework.sh output.
        .binaryTarget(
            name: "MubeenDeviceSDK",
            url: "https://github.com/mubeen-ai/Mubeen-IOS-SDK-public/releases/download/2.0.0/MubeenDeviceSDK.xcframework.zip",
            checksum: "5d50d72934d9759f025cbfe7e8282ad28a3d15547be5e7bbb9ba65db065147f1"
        ),

        // Local alternative (for testing before you host the zip):
        // .binaryTarget(name: "MubeenDeviceSDK", path: "MubeenDeviceSDK.xcframework"),
    ]
)
