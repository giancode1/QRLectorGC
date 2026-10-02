// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QRLectorGC",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "QRLectorGC", path: "Sources/QRLector")
    ]
)
