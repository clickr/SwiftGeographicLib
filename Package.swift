// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGeographicLib",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Geodesic",
            targets: ["Geodesic"]),
        .library(
            name: "GeodesicLine",
            targets: ["GeodesicLine"]),
        .library(
            name: "GeographicError",
            targets: ["GeographicError"]
        ),
        .library(
            name: "GeographicLib",
            targets: ["GeographicLib"]),
        .library(
            name: "MagneticModel",
            targets: ["MagneticModel"]),
        .library(
            name: "TransverseMercator",
            targets: ["TransverseMercator"]),
        .library(
            name: "Utility",
            targets: ["Utility"]
        ),
        .library(
            name: "UTMUPS",
            targets: ["UTMUPS"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0")],
    targets: [
        .target(
            name: "GeoConstants"),
        .target(
            name: "Geodesic",
            dependencies: ["GeographicLib", "GeographicError"],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .target(
            name: "GeodesicLine",
            dependencies: ["GeographicLib", "Geodesic", "GeographicError", "GeoConstants"],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .target(
            name: "GeographicError"),
        .target(
            name: "GeographicLib",
            exclude: ["AUTHORS",
                      "CMakeLists.txt",
                      "HOWTO-RELEASE.txt",
                      "LICENSE.txt",
                      "Makefile.am",
                      "include/Makefile.am",
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
            sources: ["src"],
            cxxSettings: [
                .headerSearchPath("include"),
                .define("GEOGRAPHICLIB_VERSION_STRING", to: "\"2.5\""),
                .define("GEOGRAPHICLIB_VERSION_MAJOR", to: "2"),
                .define("GEOGRAPHICLIB_VERSION_MINOR", to: "5"),
                .define("GEOGRAPHICLIB_VERSION_PATCH", to: "0"),
                .define("GEOGRAPHICLIB_DATA", to: "\"/usr/local/share/GeographicLib\""),
                .define("GEOGRAPHICLIB_HAVE_LONG_DOUBLE", to: "0"),
                .define("GEOGRAPHICLIB_WORDS_BIGENDIAN", to: "0"),
                .define("GEOGRAPHICLIB_PRECISION", to: "2"),
                .define("GEOGRAPHICLIB_SHARED_LIB", to: "0")
            ]),
        .target(
            name: "MagneticModel",
            dependencies: ["GeographicLib"],
            resources: [.process("Resources")],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .target(
            name: "Rumb",
            dependencies: ["GeographicLib", "GeographicError"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .target(
            name: "TransverseMercator",
            dependencies: ["GeographicLib", "GeoConstants", "GeographicError"],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .target(
            name: "Utility",
            dependencies: ["GeographicLib"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .target(
            name: "UTMUPS",
            dependencies: ["GeographicLib", "TransverseMercator", "GeographicError"],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .testTarget(
            name: "GeoConstantsTests",
            dependencies: ["GeographicLib", "GeoConstants"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .testTarget(
            name: "GeodesicTests",
            dependencies: ["Geodesic", .product(name: "RealModule", package: "swift-numerics")],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .testTarget(
            name: "GeographicLibTests",
            dependencies: ["GeographicLib", .product(name: "RealModule", package: "swift-numerics")],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .testTarget(
            name: "MagneticModelTests",
            dependencies: ["MagneticModel", .product(name: "RealModule", package: "swift-numerics")],
            swiftSettings: [.interoperabilityMode(.Cxx)]),
        .testTarget(
            name: "UtilityTests",
            dependencies: ["Utility", .product(name: "RealModule", package: "swift-numerics")],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .testTarget(
            name: "UTMUPSTests",
            dependencies: ["UTMUPS", .product(name: "RealModule", package: "swift-numerics")],
            swiftSettings: [.interoperabilityMode(.Cxx)])
    ],
    cxxLanguageStandard: .cxx20
)
