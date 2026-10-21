// swift-tools-version: 5.9
import PackageDescription

// The .xcframeworks are committed under SDK/, so these are path-based binary
// targets: resolving the package is a plain git clone, with nothing to download
// and nothing compiled from source.
let package = Package(
    name: "AssistCobrowse",

    // 15.0, not 13.0: AssistCobrowse itself supports iOS 13, but the bundled
    // ZSocketHandler.xcframework is built with a minos of 15.0. Declaring 13.0
    // here would let an app targeting iOS 13/14 link a dylib dyld refuses to
    // load, and it would crash at launch. Dropping ZSocketHandler below would
    // allow 13.0 again.
    platforms: [.iOS(.v15)],

    products: [
        // Both binaries ship, so both targets belong to the product — Xcode
        // links and embeds every binary target the product names.
        .library(
            name: "AssistCobrowse",
            targets: ["AssistCobrowse", "ZSocketHandler"]
        )
    ],

    targets: [
        .binaryTarget(
            name: "AssistCobrowse",
            path: "SDK/AssistCobrowse.xcframework"
        ),
        .binaryTarget(
            name: "ZSocketHandler",
            path: "SDK/ZSocketHandler.xcframework"
        )
    ]
)
