//
//  GeodesicLine.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 3/8/2025.
//

import Foundation
@preconcurrency import GeographicLib
import CoreLocation
import Geodesic
@_exported import GeographicError
import GeoConstants

/**
 Represents a geodesic line segment on an ellipsoidal Earth model, enabling queries for coordinates and azimuths along the geodesic.

 A `GeodesicLine` is constructed from either two coordinates (solving the inverse geodesic problem) or from a starting coordinate, initial azimuth, and distance (solving the direct geodesic problem). It provides:
 - The total length of the geodesic segment
 - Positions, azimuths, and arc length at any point along the geodesic

 This struct acts as a Swift wrapper around GeographicLib's geodesic line functionality and uses double-precision calculations for high accuracy. All coordinates are expressed in `CLLocationCoordinate2D`.
*/
public struct GeodesicLine {
    public let line : GeographicLib.GeodesicLine
    /// GeodesicLine with start and end coordinates
    ///
    /// - Throws: `CoordinateError.illegalLatitude` if startCoordinate.latitude or endCoordinate.latitude not in -90&deg;...90&deg;
    public init(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D, geodesic: Geodesic = Geodesic.WGS84) throws {
        guard startCoordinate.latitude >= -90, startCoordinate.latitude <= 90, endCoordinate.latitude >= -90, endCoordinate.latitude <= 90 else {
            if startCoordinate.latitude < -90 || startCoordinate.latitude > 90 {
                throw CoordinateError.illegalLatitude(latitude: startCoordinate.latitude)
            } else {
                throw CoordinateError.illegalLatitude(latitude: endCoordinate.latitude)
            }
        }
        line = geodesic.inverseLine(startCoordinate: startCoordinate, endCoordinate: endCoordinate)
    }
    /// GeodesicLine with start coordinate, azimuth, and distance
    public init(startCoordinate: CLLocationCoordinate2D, azimuth: CLLocationDegrees, distance: Double, geodesic: Geodesic = Geodesic.WGS84) throws {
        guard startCoordinate.latitude >= -90, startCoordinate.latitude <= 90 else {
            throw CoordinateError.illegalLatitude(latitude: startCoordinate.latitude)
        }
        line = geodesic.directLine(startCoordinate: startCoordinate, azimuth: azimuth, distance: distance)
    }
    
    public var length: Double {
        return line.Distance()
    }
    /// Get the position, azimuth, and arc length at a given distance on a GeodesicLine
    /// - Parameter distance: distance in metres along the line. can be negative
    /// - Returns: a tuple containing the computed coordinate (CLLocationCoordinate2D), azimuth (Double),
    /// and arc length (Double)
    public func position(at distance: Double) -> (coordinate: CLLocationCoordinate2D,
                                                  azimuth: Double,
                                                  arcLength: Double) {
        var lat: Double = .nan
        var lon: Double = .nan
        var azimuth: Double = .nan
        let arcLength: Double = line.Position(distance, &lat, &lon, &azimuth)
        
        return (coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), azimuth: azimuth, arcLength: arcLength)
    }
    
    public var origin : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: line.Latitude(), longitude: line.Longitude())
    }
    
    public var azimuth : Double {
        return line.Azimuth()
    }
    
    public static let originUnit : GeodesicLine = try! GeodesicLine(startCoordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), azimuth: 0, distance: 1)
}

