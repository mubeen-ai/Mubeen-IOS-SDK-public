// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MubeenDeviceSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MubeenDeviceSDK",
            targets: ["MubeenDeviceSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "MubeenDeviceSDK",
            url: "https://github.com/mubeen-ai/MubeenDeviceSDK/releases/download/1.0.0/MubeenDeviceSDK.xcframework.zip",
            checksum: "10bf7f17e0779c5c3433b1b9613467816834b12a82d5a59d970c372624b541f7"
        ),
    ]
)
