//
//  Geodesic.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 29/7/2025.
//

import GeographicLib
import CoreLocation
@_exported import GeographicError

typealias Constants = GeographicLib.Constants

public struct Geodesic : Sendable {
    /// A global instantiation of Geodesic with the parameters for the WGS84 ellipsoid.
    public static let WGS84 = Geodesic()
    private let geoid : GeographicLib.Geodesic
    ///
    /// Constructor for an ellipsoid with
    ///
    /// - Parameters
    ///     - equatorialRadius: a equatorial radius (meters).
    ///     - f: flattening of ellipsoid.  Setting  f = 0 gives a sphere.
    ///   Negative  f gives a prolate ellipsoid.
    ///     - exact: if true use exact formulation in terms of elliptic
    ///   integrals instead of series expansions (default false).
    ///
    /// - Throws: `GeodesicError.nonPositiveRadius` if equatorialRadius <= 0
    ///
    /// - Throws:  `GeodesicError.oneMinusFlatteningNotPositive` if  (1 &minus;  flattening) <= 0.
    ///
    /// With exact = true, this class delegates the calculations to the
    /// GeodesicExact and GeodesicLineExact classes which solve the geodesic
    /// problems in terms of elliptic integrals.
    public init(equatorialRadius: Double ,flattening: Double, exact: Bool = false) throws(GeodesicError) {
        guard equatorialRadius > 0 else {
            throw GeodesicError.equatorialRadiusNotPositive
        }
        guard (1 - flattening) > 0 else {
            throw GeodesicError.polarSemiAxisNotPositive
        }
        geoid = GeographicLib
            .Geodesic(equatorialRadius, flattening, exact)
    }
    public func inverseLine(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) -> GeographicLib.GeodesicLine {
        return geoid.InverseLine(startCoordinate.latitude, startCoordinate.longitude, endCoordinate.latitude, endCoordinate.longitude)
    }
    public func directLine(startCoordinate: CLLocationCoordinate2D, azimuth: Double, distance: Double) -> GeographicLib.GeodesicLine {
        return geoid.DirectLine(startCoordinate.latitude, startCoordinate.longitude, azimuth, distance)
    }
    ///
    /// Solve the direct geodesic problem where the length of the geodesic
    /// is specified in terms of distance.
    ///
    /// - Parameters:
    ///     - origin: start point (CLLocationCoordinate2D)
    ///     - azimuth: bearing at origin (degrees)
    ///     - distance: geodesic distance (metres)
    /// - Throws: `GeodesicError.illegalLatitude` if `origin.latitude` is outside
    /// of range [&minus;90&deg;, 90&deg;]
    /// - Returns: a tuple containing the `forwardAzimuth`, the `destination` location, and the `arcLength` of the geodesic path (an arcLenth greater than 180&deg; signifies a geodesic which is not a shortest path.
    ///
    /// The return values of
    ///  `destination.longitude` and `forwardAzimuth` are in the range [&minus;180&deg;,
    /// 180&deg;].
    ///
    /// `forwardAzimuth` is the azimuth at the destination
    ///
    /// If either point is at a pole, the azimuth is defined by keeping the
    /// longitude fixed, writing \e lat = &plusmn;(90&deg; &minus; &epsilon;),
    /// and taking the limit &epsilon; &rarr; 0+.  (For a
    /// prolate ellipsoid, an additional condition is necessary for a shortest
    /// path: the longitudinal extent must not exceed of 180&deg;.)
    ///

    public func direct(origin: CLLocationCoordinate2D, azimuth: Double, distance: Double)
    throws-> (arcLength: Double,
                             forwardAzimuth: Double,
                             destination: CLLocationCoordinate2D) {
        guard origin.latitude <= 90 && origin.latitude >= -90 else {
            throw CoordinateError.illegalLatitude(latitude: origin.latitude)
        }
        var lat : Double = .nan
        var lon : Double = .nan
        var forwardAzimuth : Double = .nan
        let arcLength = geoid.Direct(origin.latitude,
                                     origin.longitude,
                                     azimuth, distance,
                                     &lat,
                                     &lon,
                                     &forwardAzimuth)
        return (arcLength: arcLength,
                forwardAzimuth: forwardAzimuth,
                destination: CLLocationCoordinate2D(latitude: lat, longitude: lon))
    }
    ///
    /// Solve the inverse geodesic problem.
    ///
    /// - Parameter origin: location coordinate of the origin
    /// - Parameter destination: location coordinate of the destination
    /// - Returns: a tuple containing the `arcLength`, `azimuth`, `forwardAzimuth`, and `distance`
    /// - Throws: `CoordinateError.illegalLatitude` if origin.latitude or destination.latitude outside of range [-90&deg;, 90&deg;]
    ///
    /// The values of `azimuth` and `forwardAzimuth` returned are in the range
    /// [&minus;180&deg;, 180&deg;].
    ///
    /// If either point is at a pole, the azimuth is defined by keeping the
    /// longitude fixed, writing \e lat = &plusmn;(90&deg; &minus; &epsilon;),
    /// and taking the limit &epsilon; &rarr; 0+.
    ///
    /// The solution to the inverse problem is found using Newton's method.  If
    /// this fails to converge (this is very unlikely in geodetic applications
    /// but does occur for very eccentric ellipsoids), then the bisection method
    /// is used to refine the solution.
    public func inverse(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) throws(CoordinateError) -> (arcLength: Double, azimuth: Double, forwardAzimuth: Double, distance: Double) {
        guard origin.latitude <= 90 && origin.latitude >= -90 else {
            throw .illegalLatitude(latitude: origin.latitude)
        }
        guard destination.latitude <= 90 && destination.latitude >= -90 else {
            throw .illegalLatitude(latitude: destination.latitude)
        }
        var azimuth : Double = .nan
        var forwardAzimuth : Double = .nan
        var distance : Double = .nan
        let arcLength = geoid.Inverse(origin.latitude, origin.longitude,
                      destination.latitude, destination.longitude, &distance,
                      &azimuth, &forwardAzimuth)
        return (arcLength: arcLength,
                azimuth: azimuth,
                forwardAzimuth: forwardAzimuth,
                distance: distance)
    }
    
    private init() {
        geoid = GeographicLib.Geodesic.WGS84().pointee
    }
}
