//
//  File.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 28/7/2025.
//

import Testing
@testable import UTMUPS
import RealModule

/// Test Location - Kulun Station
///
/// Kulun Station is the second most southern Antarctic research station
/// the most southern being the Amundsen-Scott south pole station
/// [Wikipedia](https://en.wikipedia.org/wiki/Kunlun_Station)
@Test func kulunStation() throws {
//    echo -80.4174 77.1166 | GeoConvert -u -p 9
//    s 3039440.641302266 2237746.759453198
    let kunlun = try UPS(latitude: -80.4174, longitude: 77.1166)
    #expect(kunlun.hemisphere == .southern)
    #expect(kunlun.easting.isApproximatelyEqual(to: 3039440.641302266, absoluteTolerance: 1e-9))
    #expect(kunlun.northing.isApproximatelyEqual(to: 2237746.759453198, absoluteTolerance: 1e-9))
    
//    echo -80.4174 77.1166 | GeoConvert -u -p 9 -c
//    -77.1166000000000 1.000982886651784
    #expect(kunlun.convergence.isApproximatelyEqual(to: -77.1166000000000, absoluteTolerance: 1e-9))
    #expect(kunlun.scale.isApproximatelyEqual(to: 1.000982886651784, absoluteTolerance: 1e-9))
}

/// Test Location - Barneo
///
/// The Frigg Fjord is thought to be the most northern settlement in human history
/// last inhabited over 2400 years ago
/// [Wikipedia](https://en.wikipedia.org/wiki/Frigg_Fjord)
@Test func barneo() throws {
//    echo 89.5249979 -30.4499982 | GeoConvert -u -p 9 -z 0
//    n 1973273.698017827 1954537.063512382
    
    let barneo = try UPS(latitude: 89.5249979, longitude: -30.4499982)
    #expect(barneo.hemisphere == .northern)
    #expect(barneo.easting.isApproximatelyEqual(to: 1973273.698017827, absoluteTolerance: 1e-9))
    #expect(barneo.northing.isApproximatelyEqual(to: 1954537.063512382, absoluteTolerance: 1e-9))
    
//    echo 89.5249979 -30.4499982 | GeoConvert -u -p 9 -z 0 -c
//    -30.4499982000000 0.994017079575084
    #expect(barneo.convergence.isApproximatelyEqual(to: -30.4499982000000, absoluteTolerance: 1e-9))
    #expect(barneo.scale.isApproximatelyEqual(to: 0.994017079575084, absoluteTolerance: 1e-9))
}
    
