// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChooseBrowser",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "ChooseBrowser",
            path: "ChooseBrowser"
        )
    ]
)
