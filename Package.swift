// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZZCustomControl",
    products: [
        .library(
            name: "ZZCustomControl",
            targets: ["ZZCustomControl"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/CZ410/ZZBase.git", .upToNextMajor(from: "0.2.0"))
    ],
    targets: [
        .target(
            name: "ZZCustomControl",
            dependencies: [],
            path: "Sources"
        ),
    ]
)
