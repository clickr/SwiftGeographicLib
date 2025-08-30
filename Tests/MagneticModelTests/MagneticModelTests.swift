//
//  MagneticModelTests.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 16/8/2025.
//
import Foundation
import CoreLocation
import Testing
import RealModule
@testable import MagneticModel

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

let ypph = CLLocationCoordinate2D(latitude: -31.93980, longitude: 115.96650)

@Test func wmm2025() throws {
    let model = MagneticModel.wmm2025
    let date = dateFormatter.date(from: "2025-08-16")!
    
//    echo 2025-08-16 -31.93980 115.96650 | MagneticField
//    -1.48 -65.83 23940.6 23932.6 -617.1 -53343.1 58469.1
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.48, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -65.83, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23940.6, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58469.1, absoluteTolerance: 1e-1))
}

@Test func wmmhr2025() throws {
    let model = MagneticModel.wmmhr2025
    let date = dateFormatter.date(from: "2025-08-16")!

//    echo 2025-08-16 -31.93980 115.96650 | MagneticField -n wmmhr2025
//    -1.61 -65.78 23961.9 23952.4 -674.4 -53274.8 58415.6
    
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.61, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -65.78, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23961.9, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58415.6, absoluteTolerance: 1e-1))
}

@Test func emm2010() throws {
    //    echo 2014-08-16 -31.93980 115.96650 | MagneticField -n emm2010
    //    -1.96 -66.13 23590.9 23577.1 -805.7 -53305.8 58292.7
    let model = MagneticModel.emm2010
    let date = dateFormatter.date(from: "2014-08-16")!
    
    
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.96, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -66.13, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23590.9, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58292.7, absoluteTolerance: 1e-1))
}


@Test func wmm2010() throws {
    let model = MagneticModel.wmm2010
    let date = dateFormatter.date(from: "2014-08-16")!
    
    //    echo 2014-08-16 -31.93980 115.96650 | MagneticField -n wmm2010
    //    -1.58 -66.26 23453.1 23444.2 -645.4 -53314.8 58245.3
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.58, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -66.26, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23453.1, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58245.3, absoluteTolerance: 1e-1))
}

/// Enhanced Magnetic Model 2015
@Test func emm2015 () throws {
    //    echo 2015-08-16 -31.93980 115.96650 | MagneticField -n emm2015
    //    -1.99 -66.05 23684.4 23670.1 -822.4 -53317.5 58341.3
    let model = MagneticModel.emm2015
    let date = dateFormatter.date(from: "2015-08-16")!
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.99, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -66.05, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23684.4, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58341.3, absoluteTolerance: 1e-1))
}

// Enhanced Magnetic Model 2017
@Test func emm2017 () throws {
    //    echo 2017-08-16 -31.93980 115.96650 | MagneticField -n emm2017
    //    -1.83 -65.95 23769.5 23757.4 -758.3 -53265.4 58328.3
    let model = MagneticModel.emm2017
    let date = dateFormatter.date(from: "2017-08-16")!
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.83, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -65.95, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23769.5, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58328.3, absoluteTolerance: 1e-1))
}

/// International Geomagnetic Reference Field - 11th Generation Test
@Test func igrf11 () throws {
    //    echo 2010-08-16 -31.93980 115.96650 | MagneticField -n igrf11
    //    -1.66 -66.42 23355.4 23345.5 -677.9 -53505.1 58380.4
    let model = MagneticModel.igrf11
    let date = dateFormatter.date(from: "2010-08-16")!
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.66, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -66.42, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23355.4, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58380.4, absoluteTolerance: 1e-1))
}
/// International Geomagnetic Reference Field - 12th Generation Test
@Test func igrf12 () throws {
    //    echo 2010-08-16 -31.93980 115.96650 | MagneticField -n igrf12
    //    -1.66 -66.41 23365.8 23355.9 -678.4 -53510.5 58389.5
    let model = MagneticModel.igrf12
    let date = dateFormatter.date(from: "2010-08-16")!
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.66, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -66.41, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23365.8, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58389.5, absoluteTolerance: 1e-1))
}
/// International Geomagnetic Reference Field - 13th Generation Test
@Test func igrf13 () throws {
    //    echo 2015-08-16 -31.93980 115.96650 | MagneticField -n igrf13
    //    -1.66 -66.14 23594.3 23584.4 -684.4 -53353.4 58337.6
    let model = MagneticModel.igrf13
    let date = dateFormatter.date(from: "2015-08-16")!
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.66, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -66.14, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23594.3, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58337.6, absoluteTolerance: 1e-1))
}
/// International Geomagnetic Reference Field - 14th Generation Test
@Test func igrf14 () throws {
    //    echo 2025-08-16 -31.93980 115.96650 | MagneticField -n igrf14
    //    -1.49 -65.82 23943.1 23934.9 -624.6 -53326.7 58455.2
    let model = MagneticModel.igrf14
    let date = dateFormatter.date(from: "2025-08-16")!
    let result = try model.modelFieldComponents(date: date, coordinate: ypph)
    #expect(result.declination.isApproximatelyEqual(to: -1.49, absoluteTolerance: 1e-2))
    #expect(result.inclination.isApproximatelyEqual(to: -65.82, absoluteTolerance: 1e-2))
    #expect(result.horizontalField.isApproximatelyEqual(to: 23943.1, absoluteTolerance: 1e-1))
    #expect(result.totalField.isApproximatelyEqual(to: 58455.2, absoluteTolerance: 1e-1))
}
