//
//  GeoCoordsErrorTests.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 2/7/2025.
//

import Testing
@testable import GeoCoords
@testable import GeographicLib

@Test func testInit() {
    #expect(throws: Never.self) {
        _ = try GeoCoords(zone: 1, northp: true, x: 0, y: 0)
    }
}

/**
     * UTM eastings are allowed to be in the range [0km, 1000km], northings are
     * allowed to be in in [0km, 9600km] for the northern hemisphere and in
     * [900km, 10000km] for the southern hemisphere.  However UTM northings
     * can be continued across the equator.  So the actual limits on the
     * northings are [-9100km, 9600km] for the "northern" hemisphere and
     * [900km, 19600km] for the "southern" hemisphere.
     *
     * UPS eastings and northings are allowed to be in the range [1200km,
     * 2800km] in the northern hemisphere and in [700km, 3300km] in the
     * southern hemisphere.
     *
     * These ranges are 100km larger than allowed for the conversions to MGRS.
     * (100km is the maximum extra padding consistent with eastings remaining
     * non-negative.)  This allows generous overlaps between zones and UTM and
     * UPS.  If \e mgrslimits = true, then all the ranges are shrunk by 100km
     * so that they agree with the stricter MGRS ranges.  No checks are
     * performed besides these (e.g., to limit the distance outside the
     * standard zone boundaries).
 **/

enum UTMUPSValidity {
    case zoneOutOfRange
    case upsOutOfRange
}

@Test func validAndInvalidNorthernUTMUPSCoordinates() {
    let xMin : Double = 0
    let xMax : Double = 1000 * 1000
    let yMin : Double = -9100 * 1000
    let yMax : Double = 9600 * 1000
    
    func NorthernGeoCoordsUTMTest(zone: Int32, x: Double, y: Double) throws {
        _ = try GeoCoords(zone: zone, northp: true, x: x, y: y)
    }
    
    #expect(throws: Never.self) {
        for zone: Int32 in 1...60 {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMin)
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMax)
            
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMin)
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMax)
        }
    }
    
    let smallDouble : Double = 1e-6
    
    #expect(throws: GeographicError.invalidLatitude) {
        _ = try GeoCoords(latitude: 90 + smallDouble, longitude: 0)
    }
    
    #expect(throws: GeographicError.zoneOutOfRange) {
        try NorthernGeoCoordsUTMTest(zone: -1, x: 1200000, y: 1200000)
    }
    
    #expect(throws: GeographicError.zoneOutOfRange) {
        try NorthernGeoCoordsUTMTest(zone: 61, x: xMin, y: yMin)
    }
    
    
    #expect(throws: GeographicError.upsOutOfRange) {
        try NorthernGeoCoordsUTMTest(zone: 0, x: 1200000 - smallDouble, y: 1200000)
    }
    
    #expect(throws: GeographicError.upsOutOfRange) {
        try NorthernGeoCoordsUTMTest(zone: 0, x: 1200000, y: 1200000 - smallDouble)
    }
    
    #expect(throws: GeographicError.upsOutOfRange) {
        try NorthernGeoCoordsUTMTest(zone: 0, x: 2800000 + smallDouble, y: 2800000)
    }
    
    #expect(throws: GeographicError.upsOutOfRange) {
        try NorthernGeoCoordsUTMTest(zone: 0, x: 2800000, y: 2800000 + smallDouble)
    }
    
    for zone: Int32 in 1...60 {
        #expect(throws: GeographicError.utmOutOfRange) {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMin - smallDouble, y: yMin)
        }
        
        #expect(throws: GeographicError.utmOutOfRange) {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMax + smallDouble, y: yMax)
        }
        
        #expect(throws: GeographicError.utmOutOfRange) {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMax + smallDouble, y: yMin)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMin - smallDouble, y: yMax)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMin - smallDouble)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMax + smallDouble)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMin - smallDouble)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try NorthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMax + smallDouble)
        }
    }
}

@Test func validAndInvalidSouthernUTMUPSCoordinates() {
    let xMin : Double = 0
    let xMax : Double = 1000 * 1000
    let yMin : Double = 900 * 1000
    let yMax : Double = 19600 * 1000
    let utmMin : Double = 700 * 1000
    let utmMax : Double = 3300 * 1000
    
    func SouthernGeoCoordsUTMTest(zone: Int32, x: Double, y: Double) throws -> GeoCoords {
        return try GeoCoords(zone: zone, northp: false, x: x, y: y)
    }
    
    #expect(throws: Never.self) {
        for zone: Int32 in 1...60 {
            _ = try SouthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMin)
            _ = try SouthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMax)
            
            _ = try SouthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMin)
            _ = try SouthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMax)
        }
    }
    
    let smallDouble : Double = 1e-6
    
    for zone: Int32 in 1...60 {
        #expect(throws: GeographicError.latitudeLongitudeIllegalForUTMZone) {
            let c1 = try SouthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMin)
            _ = try GeoCoords(latitude: c1.latitude - smallDouble, longitude: c1.longitude, setZone: zone)
        }
        #expect(throws: GeographicError.latitudeLongitudeIllegalForUTMZone) {
            let c2 = try SouthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMax)
            _ = try GeoCoords(latitude: c2.latitude + smallDouble, longitude: c2.longitude, setZone: zone)
        }
        #expect(throws: GeographicError.latitudeLongitudeIllegalForUTMZone) {
            let c3 = try SouthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMin)
            _ = try GeoCoords(latitude: c3.latitude - smallDouble, longitude: c3.longitude, setZone: zone)
        }
        #expect(throws: GeographicError.latitudeLongitudeIllegalForUTMZone) {
            let c4 = try SouthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMax)
            _ = try GeoCoords(latitude: c4.latitude + smallDouble, longitude: c4.longitude, setZone: zone)
        }
    }
    
    #expect(throws: GeographicError.invalidLatitude) {
        _ = try GeoCoords(latitude: -90 - smallDouble, longitude: 0)
    }
    
    #expect(throws: GeographicError.zoneOutOfRange) {
        try SouthernGeoCoordsUTMTest(zone: -1, x: xMin, y: yMin)
    }
    
    #expect(throws: GeographicError.zoneOutOfRange) {
        try SouthernGeoCoordsUTMTest(zone: 61, x: xMin, y: yMin)
    }
    
    #expect(throws: GeographicError.upsOutOfRange) {
        try SouthernGeoCoordsUTMTest(zone: 0, x: utmMin - smallDouble, y: utmMin)
    }
    #expect(throws: GeographicError.upsOutOfRange) {
        try SouthernGeoCoordsUTMTest(zone: 0, x: utmMin, y: utmMin - smallDouble)
    }
    
    #expect(throws: GeographicError.upsOutOfRange) {
        try SouthernGeoCoordsUTMTest(zone: 0, x: utmMax + smallDouble, y: utmMax)
    }
    
    #expect(throws: GeographicError.upsOutOfRange) {
        try SouthernGeoCoordsUTMTest(zone: 0, x: utmMax, y: utmMax + smallDouble)
    }
    
    for zone: Int32 in 1...60 {
        #expect(throws: GeographicError.utmOutOfRange) {
            try SouthernGeoCoordsUTMTest(zone: zone, x: xMin - smallDouble, y: yMin)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try SouthernGeoCoordsUTMTest(zone: zone, x: xMax + smallDouble, y: yMax)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try SouthernGeoCoordsUTMTest(zone: zone, x: xMax + smallDouble, y: yMin)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try SouthernGeoCoordsUTMTest(zone: zone, x: xMin - smallDouble, y: yMax)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try SouthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMin - smallDouble)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try SouthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMax + smallDouble)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try SouthernGeoCoordsUTMTest(zone: zone, x: xMax, y: yMin - smallDouble)
        }
        #expect(throws: GeographicError.utmOutOfRange) {
            try SouthernGeoCoordsUTMTest(zone: zone, x: xMin, y: yMax + smallDouble)
        }
    }
}
