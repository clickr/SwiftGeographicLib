// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGeographicLib",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftGeographicLib",
            targets: ["SwiftGeographicLib"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftGeographicLib",
            exclude: ["GeographicLib/AUTHORS",
                      "GeographicLib/CMakeLists.txt",
                      "GeographicLib/HOWTO-RELEASE.txt",
                      "GeographicLib/LICENSE.txt",
                      "GeographicLib/Makefile.am",
                      "GeographicLib/NEWS",
                      "GeographicLib/README.md",
                      "GeographicLib/autogen.sh",
                      "GeographicLib/cgi-bin",
                      "GeographicLib/cmake",
                      "GeographicLib/configure.ac",
                      "GeographicLib/data-distrib",
                      "GeographicLib/data-installer",
                      "GeographicLib/develop/",
                      "GeographicLib/doc",
                      "GeographicLib/examples",
                      "GeographicLib/experimental",
                      "GeographicLib/include/Makefile.am",
                      "GeographicLib/m4",
                      "GeographicLib/makefile-admin",
                      "GeographicLib/man",
                      "GeographicLib/maxima",
                      "GeographicLib/src/CMakeLists.txt",
                      "GeographicLib/src/Makefile.am",
                      "GeographicLib/tests",
                      "GeographicLib/tools/",
                      "GeographicLib/wrapper"],
            cxxSettings: [
                .headerSearchPath("./extra/"),
                .headerSearchPath("./GeographicLib/include/"),
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
        .testTarget(
            name: "SwiftGeographicLibTests",
            dependencies: ["SwiftGeographicLib"]
        ),
    ],
    cxxLanguageStandard: .cxx20
)
