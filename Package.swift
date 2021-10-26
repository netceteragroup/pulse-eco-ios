// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PulseEco",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PulseEco",
            targets: ["PulseEco"]),
    ],
    dependencies: [
        .package(name: "Lottie", url: "https://github.com/airbnb/lottie-ios.git", from: "3.2.1"),
        .package(url: "https://github.com/danielgindi/Charts.git", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PulseEco",
            dependencies: ["Lottie",
                           "Charts"]),
        .testTarget(
            name: "PulseEcoTests",
            dependencies: ["PulseEco"]),
    ]
)
