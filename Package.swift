import PackageDescription

let package = Package(
    name: "Kunugi",
    dependencies: [
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0)
    ]
)