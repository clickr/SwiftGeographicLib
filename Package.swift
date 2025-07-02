// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGeographicLib",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GeoCoords",
            targets: ["GeoCoords"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "GeographicLib",
                exclude: ["AUTHORS",
                          "CMakeLists.txt",
                          "HOWTO-RELEASE.txt",
                          "LICENSE.txt",
                          "Makefile.am",
                          "NEWS",
                          "README.md",
                          "autogen.sh",
                          "cgi-bin",
                          "cmake",
                          "configure.ac",
                          "data-distrib",
                          "data-installer",
                          "develop/",
                          "doc",
                          "examples",
                          "experimental",
                          "include/Makefile.am",
                          "m4",
                          "makefile-admin",
                          "man",
                          "maxima",
                          "src/CMakeLists.txt",
                          "src/Makefile.am",
                          "tests",
                          "tools/",
                          "wrapper"],
                cxxSettings: [
                    .define("GEOGRAPHICLIB_VERSION_STRING", to: "\"2.5\""),
                    .define("GEOGRAPHICLIB_VERSION_MAJOR", to: "2"),
                    .define("GEOGRAPHICLIB_VERSION_MINOR", to: "5"),
                    .define("GEOGRAPHICLIB_VERSION_PATCH", to: "0"),
                    .define("GEOGRAPHICLIB_DATA", to: "\"/usr/local/share/GeographicLib\""),
                    .define("GEOGRAPHICLIB_HAVE_LONG_DOUBLE", to: "0"),
                    .define("GEOGRAPHICLIB_WORDS_BIGENDIAN", to: "0"),
                    .define("GEOGRAPHICLIB_PRECISION", to: "3"),
                    .define("GEOGRAPHICLIB_SHARED_LIB", to: "0")
                ]),
        .target(name: "Math",
                dependencies: ["GeographicLib"],
                swiftSettings: [.interoperabilityMode(.Cxx)]),
        .target(
            name: "UTMUPS",
            dependencies: ["GeographicLib"],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .target(name: "GeoCoords",
                dependencies: ["UTMUPS", "Math"],
                swiftSettings: [.interoperabilityMode(.Cxx)]),
        .testTarget(name: "GeoCoordsTests",
                    dependencies: ["GeoCoords", .product(name: "RealModule", package: "swift-numerics")],
                    swiftSettings: [.interoperabilityMode(.Cxx)])
    ],
    cxxLanguageStandard: .cxx20
)
