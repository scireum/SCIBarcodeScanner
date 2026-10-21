// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "SCIBarcodeScanner",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "SCIBarcodeScanner", targets: ["SCIBarcodeScanner"])
    ],
    targets: [
        .target(
            name: "SCIBarcodeScanner",
            path: "SCIBarcodeScanner",
            // images (asset catalog) and translations, accessed via Bundle.module (see Helper)
            resources: [.process("Resources")]
        )
    ],
    swiftLanguageVersions: [.v5]
)
