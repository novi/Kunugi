import PackageDescription

let package = Package(
    name: "Kunugi",
    dependencies: [
        //.Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 9),
		.Package(url: "https://github.com/Zewo/CURIParser.git", majorVersion: 0, minor: 1)
    ]
)