//
//  Rumb.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 28/8/2025.
//

import Foundation
import GeographicLib
import GeographicError
import CoreLocation

/// \brief Solve of the direct and inverse rhumb problems.
///
/// The path of constant azimuth between two points on an ellipsoid at  is called the rhumb line (also
/// called the loxodrome).  It has a length and azimuth.
/// (The azimuth is the heading measured clockwise from north.)
///
/// Given a start coordinate, azimuth, and distance, we can determine the end coordinate.
/// This is the `direct` rhumb problem and its use can be exemplified by:
/// ```swift
/// let destination : CLLocationCoordinate2D =
///     direct(coordinate: CLLocationCoordinate2D,
///            azimuth: Double,
///            distance: Double).
/// ```
/// Given a start coordinate and end coordinate, we can determine azimuth
/// and distance.  This is the `inverse` rhumb problem, whose solution is given
/// by
/// ```swift
/// let azimuthDistance : (azimuth: Double, distance: Double) =
///     inverse(startCoordinate: CLLocationCoordinate2D,
///             endCoordinate: CLLocationCoordinate2D)
/// ```
/// This finds the shortest such rhumb line, i.e., the one
/// that wraps no more than half way around the earth.  If the end points are
/// on opposite meridians, there are two shortest rhumb lines and the
/// east-going one is chosen.
public struct Rumb {
    private let rumb : GeographicLib.Rhumb
    public init(equatorialRadius: Double, flattening: Double, exact: Bool = false) throws {
        guard equatorialRadius > 0 else {
            throw GeodesicError.equatorialRadiusNotPositive
        }
        guard 1-flattening > 0 else {
            throw GeodesicError.polarSemiAxisNotPositive
        }
        self.rumb = GeographicLib.Rhumb(equatorialRadius, flattening, exact)
    }
    
    /// Get the coordinate a given direction and distance along a rhumb line
    ///
    /// - Throws: `CoordinateError.illegalLatitude` if coordinate.latitude not in -90&deg;...90&deg;
    public func direct(coordinate: CLLocationCoordinate2D, azimuth: Double, distance: Double) throws -> CLLocationCoordinate2D {
        guard coordinate.latitude >= -90 && coordinate.latitude <= 90 else {
            throw CoordinateError.illegalLatitude(latitude: coordinate.latitude)
        }
        var destLat : Double = .nan
        var destLon : Double = .nan
        rumb.Direct(coordinate.latitude, coordinate.longitude, azimuth, distance, &destLat, &destLon)
        return CLLocationCoordinate2D(latitude: destLat, longitude: destLon)
    }
    
    /// Get the azimuth and distance for a rhumb line defined by 2 coordinates
    ///
    /// - Throws: `CoordinateError.illegalLatitude` if either coordinate latitude is not in -90&deg;...90&deg;
    public func inverse(coordinate: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) throws -> (azimuth: Double, distance: Double) {
        guard coordinate.latitude >= -90 && coordinate.latitude <= 90 else {
            throw CoordinateError.illegalLatitude(latitude: coordinate.latitude)
        }
        guard destination.latitude >= -90 && destination.latitude <= 90 else {
            throw CoordinateError.illegalLatitude(latitude: destination.latitude)
        }
        var azimuth : Double = .nan
        var distance : Double = .nan
        rumb.Inverse(coordinate.latitude, coordinate.longitude, destination.latitude, destination.longitude, &distance, &azimuth)
        return (azimuth: azimuth, distance: distance)
    }
}
