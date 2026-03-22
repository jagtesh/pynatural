// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PyNatural",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PyNatural", type: .dynamic, targets: ["PyNatural"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jagtesh/ApplePy.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "PyNatural",
            dependencies: [
                .product(name: "ApplePy", package: "ApplePy"),
                .product(name: "ApplePyClient", package: "ApplePy"),
            ]
        ),
    ]
)
