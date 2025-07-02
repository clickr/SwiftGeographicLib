//
//  GeoCoordsTests.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 3/7/2025.
//

import Testing
@testable import GeoCoords
import RealModule

@Test func test1() throws {
//    echo -31.94028333 115.96695 | GeoConvert -u -s -p 9
//    50s 402357.369285629 6465717.701277924
    
    let c1 = try GeoCoords(latitude: -31.94028333, longitude: 115.96695)
    #expect(c1.zone == 50)
    #expect(c1.x.isApproximatelyEqual(to: 402357.369285629, absoluteTolerance: 1e-9))
    #expect(c1.y.isApproximatelyEqual(to: 6465717.701277924, absoluteTolerance: 1e-9))
    
//    echo -31.94028333 115.96695 | GeoConvert -u -s -p 9 -c
//    0.5465629794442 0.999717579467930
    
    #expect(c1.convergence.isApproximatelyEqual(to: 0.5465629794442, absoluteTolerance: 1e-9))
    #expect(c1.scale.isApproximatelyEqual(to: 0.999717579467930, absoluteTolerance: 1e-9))
    
    let c2 = try GeoCoords(latitude: -31.94028333, longitude: 115.96695, setZone: 49)
    #expect(c2.zone == 49)
}
