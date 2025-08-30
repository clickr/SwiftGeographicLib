//
//  ConstantsTests.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 14/8/2025.
//

import Testing
@testable import GeoConstants
@testable import GeographicLib

@Test func contantsMatch() {
    #expect(GeographicLib.Constants.WGS84_a() == GeoConstants.WGS84_equatorialRadius)
    #expect(GeographicLib.Constants.WGS84_f() == GeoConstants.WGS84_flattening)
    #expect(GeographicLib.Constants.WGS84_omega() == GeoConstants.WGS84_AngularVelocity)
    #expect(GeographicLib.Constants.WGS84_GM() == GeoConstants.WGS84_GravitationalConstant)
    #expect(GeographicLib.Constants.UTM_k0() == GeoConstants.UTM_CentralScaleFactor)
    
}
