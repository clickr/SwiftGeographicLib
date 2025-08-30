//
//  File.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 28/7/2025.
//

import Foundation
import GeographicLib
import GeoConstants
import CoreLocation
@_exported import GeographicError

public enum TransverseMercatorError : Error {
    /// Equatorial Radius must be positive
    case equatorialRadiusNotPositive
    /// Flattening must be less than 1
    case polarSemiAxisNotPositive
    /// Scale must be positive
    case scaleNotPositive
    /// Use exact solution to extend
    case transverseMercatorNotExact
    /// Latitude must be in range [-90&deg;, 90&deg;]
    case illegalLatitude(latitude: Double)
}

public struct TransverseMercator : Sendable {
    public static let UTM : TransverseMercator = try! TransverseMercator(
        equatorialRadius: GeoConstants.WGS84_equatorialRadius,
        flattening: GeoConstants.WGS84_flattening,
        scaleFactor: GeoConstants.UTM_CentralScaleFactor)
    
    let tm : GeographicLib.TransverseMercator
    public var equatorialRadius : Double { tm.EquatorialRadius() }
    public var flattening : Double { tm.Flattening() }
    public init(equatorialRadius: Double, flattening: Double, scaleFactor: Double, exact: Bool = false, extendP : Bool = false) throws(TransverseMercatorError) {
        guard equatorialRadius.isFinite, equatorialRadius > 0 else {
            throw .equatorialRadiusNotPositive
        }
        guard flattening.isFinite, flattening < 1 else {
            throw .polarSemiAxisNotPositive
        }
        guard scaleFactor.isFinite, scaleFactor > 0 else {
            throw .scaleNotPositive
        }
        guard !(exact == false && extendP) else {
            throw .transverseMercatorNotExact
        }
        tm = GeographicLib.TransverseMercator.init(equatorialRadius, flattening, scaleFactor, exact, extendP)
    }
    /// convert latitude and longitude to eastings and northings for a given central meridian
    /// - Throws   `TransverseMercatorError.illegalLatitude` if latitude not in [-90&deg;, 90&deg;]
    public func forward(centralMeridian: Double, latitude: Double, longitude: Double) throws -> (easting: Double, northing: Double, convergence: Double, scale: Double) {
        guard latitude >= -90 && latitude <= 90 else {
            throw CoordinateError.illegalLatitude(latitude: latitude)
        }
        var x : Double = .nan
        var y : Double = .nan
        var gamma : Double = .nan
        var k : Double = .nan
        
        tm.Forward(centralMeridian, latitude, longitude, &x, &y, &gamma, &k)
        
        return (easting: x, northing: y, convergence: gamma, scale: k)
    }
    
    public func reverse(centralMeridian: Double, x: Double, y: Double) -> (coordinate: CLLocationCoordinate2D, convergence: Double, scale: Double) {
        var latitude : Double = .nan
        var longitude : Double = .nan
        var gamma : Double = .nan
        var k : Double = .nan
        
        tm.Reverse(centralMeridian, x, y, &latitude, &longitude, &gamma, &k)
        
        return (coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                convergence: gamma,
                scale: k)
    }
}
