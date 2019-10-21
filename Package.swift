// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDWebImageSwiftUI",
    platforms: [
       .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SDWebImageSwiftUI",
            targets: ["SDWebImageSwiftUI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SDWebImageSwiftUI",
            dependencies: ["SDWebImage", "SDWebImageSwiftUIObjC"],
            path: "SDWebImageSwiftUI/Classes",
            exclude: ["ObjC"]
        ),
        // This is implementation detail because SwiftPM does not support mixed Objective-C/Swift code, don't dependent this target
        .target(
            name: "SDWebImageSwiftUIObjC",
            dependencies: ["SDWebImage"],
            path: "SDWebImageSwiftUI/Classes/ObjC",
            publicHeadersPath: "."
        )
    ]
)
