//
//  Intersect.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 9/9/2025.
//
import Foundation
import GeographicLib
import GeographicError
import GeodesicLine

public struct Intersect {
    private var geoid : GeographicLib.Geodesic
    private var intersect : GeographicLib.Intersect
    
    public init() {
        geoid = GeographicLib.Geodesic.WGS84().pointee
        intersect = GeographicLib.Intersect(geoid)
    }
    
    public func closest(line1: GeodesicLine, line2: GeodesicLine) -> (s1 : Double, s2: Double) {
        // GeographicLib.Intersect.Closest expects an output parameter of type Point (pair<CDouble, CDouble>)
        var point = GeographicLib.Intersect.Point(first: 0.0, second: 0.0)
        let res = intersect.Closest(
            line1.origin.latitude,
            line1.origin.longitude,
            line1.azimuth,
            line2.origin.latitude,
            line2.origin.longitude,
            line2.azimuth,
            point
        )
        return (s1: res.first, s2: res.second)
    }
}
