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

public struct GeodesicLine {
    private let line : GeographicLib.GeodesicLine
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
    
    public func position(at distance: Double) -> (coordinate: CLLocationCoordinate2D, azimuth: Double, arcLength: Double) {
        var lat: Double = .nan
        var lon: Double = .nan
        var azimuth: Double = .nan
        let arcLength: Double = line.Position(distance, &lat, &lon, &azimuth)
        
        return (coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), azimuth: azimuth, arcLength: arcLength)
    }
}
