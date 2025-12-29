// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Airmail2Hookmark",
    platforms: [
        .macOS(.v13)  // Required for SMAppService (launch at login)
    ],
    products: [
        .executable(
            name: "Airmail2Hookmark",
            targets: ["Airmail2Hookmark"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Airmail2Hookmark",
            dependencies: [],
            path: "Airmail2Hookmark/Sources",
            exclude: [
                "Resources/Info.plist",
                "Resources/Assets.xcassets"
            ]
        ),
        .testTarget(
            name: "Airmail2HookmarkTests",
            dependencies: ["Airmail2Hookmark"],
            path: "Airmail2Hookmark/Tests"
        )
    ]
)
