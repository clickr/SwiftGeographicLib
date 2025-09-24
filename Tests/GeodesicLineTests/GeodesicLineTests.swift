//
//  GeodesicLineTests.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 24/9/2025.
//

import Testing
@testable import GeodesicLine
import CoreLocation

@Test func originUnit() throws {
    #expect(throws: Never.self) {
        _ = try GeodesicLine(startCoordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), azimuth: 0, distance: 1)
        _ = GeodesicLine.originUnit
    }
}
