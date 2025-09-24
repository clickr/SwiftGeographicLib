//
//  UPS.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 27/7/2025.
//

import Foundation
import CoreLocation
import GeographicLib

public enum UPSError : Error {
    case invalidLatitude(latitude: Double)
    case latitudeOutOfBounds(latitude: Double)
    case eastingTooLow(easting: Double)
    case eastingTooHigh(easting: Double)
    case northingTooLow(northing: Double)
    case northingTooHigh(northing: Double)
}

typealias PolarStereopgraphic = GeographicLib.PolarStereographic

/**
 Represents a Universal Polar Stereographic (UPS) coordinate, used for mapping regions near the Earth's poles beyond the coverage of standard UTM zones.

 The UPS system provides a projected coordinate system for latitudes above 84°N and below 80°S, using polar stereographic projection. This struct encapsulates all properties needed for a UPS coordinate and supports conversion from latitude/longitude to UPS.

 - `hemisphere`: The hemisphere where the coordinate resides (.northern or .southern)
 - `easting`: The easting value in meters (relative to the UPS false origin)
 - `northing`: The northing value in meters (relative to the UPS false origin)
 - `convergence`: Meridian convergence at this point (degrees)
 - `scale`: Point scale factor at this location
 - `locationCoordinate2D`: The original Core Location coordinate

 The `UPS` struct provides:
 - Validation of latitude for UPS coverage
 - Conversion from geographic coordinates (latitude, longitude) to UPS coordinates
 - Storage of the relevant projected coordinate parameters

 Throws errors if latitude is not within the supported polar region or if the projection parameters are out of bounds.
*/
public struct UPS : UTMUPSCoordinate {
    public let hemisphere: Hemisphere
    
    public let easting: Double
    
    public let northing: Double
    
    public let convergence: Double
    
    public let scale: Double
    
    public let locationCoordinate2D: CLLocationCoordinate2D
    
    public init(latitude: Double, longitude: Double) throws(UPSError) {
        guard latitude >= -90.0 && latitude <= 90.0 else {
            throw .invalidLatitude(latitude: latitude)
        }
        guard latitude >= 83.5 || latitude < -79.5 else {
            throw .latitudeOutOfBounds(latitude: latitude)
        }
        var x : Double = .nan
        var y : Double = .nan
        var gamma : Double = .nan
        var k : Double = .nan
        let northp = latitude > 0
        
        PolarStereopgraphic
            .UPS()
            .pointee
            .Forward(northp,
                     latitude,
                     longitude,
                     &x,
                     &y,
                     &gamma,
                     &k)
        
        hemisphere = latitude > 0 ? .northern : .southern
        easting = x + upsCoordinateShift
        northing = y + upsCoordinateShift
        convergence = gamma
        scale = k
        
        locationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /**
     Initializes a UPS coordinate from a specific hemisphere, easting, and northing.

     This initializer is typically used when you already have projected UPS coordinates (e.g., from a map or an external source), and want to construct a `UPS` value directly.
     It validates the provided easting and northing values against allowed bounds for the specified hemisphere, then computes the corresponding geographic coordinate (`latitude`/`longitude`), point scale, and meridian convergence using the polar stereographic projection.

     Throws an error if the provided easting or northing values are out of bounds for UPS in the specified hemisphere.

     - Parameters:
        - hemisphere: The hemisphere where the coordinate is located (`.northern` or `.southern`).
        - easting: The easting value in meters relative to the UPS false origin.
        - northing: The northing value in meters relative to the UPS false origin.
     - Throws: `CoordinateError.eastingOutOfBounds` or `CoordinateError.northingOutOfBounds` if a value is outside valid UPS ranges.
     - Postcondition: The geographic coordinate and projection properties are computed and stored.
    */
    public init(hemisphere: Hemisphere, easting: Double, northing: Double) throws {
        if hemisphere == .northern {
            guard easting >= minUPSNorthernCoordinate && easting <= maxUPSNorthernCoordinate else {
                throw CoordinateError.eastingOutOfBounds(easting: easting)
            }
            guard northing >= minUPSNorthernCoordinate && northing <= maxUPSNorthernCoordinate else {
                throw CoordinateError.northingOutOfBounds(northing: northing)
            }
        } else {
            guard easting >= minUPSSouthernCoordinate && easting <= maxUPSSouthernCoordinate else {
                throw CoordinateError.eastingOutOfBounds(easting: easting)
            }
            guard northing >= minUPSSouthernCoordinate && northing <= maxUPSSouthernCoordinate else {
                throw CoordinateError.northingOutOfBounds(northing: northing)
            }
        }
        self.hemisphere = hemisphere
        self.easting = easting
        self.northing = northing
        var convergence : Double = .nan
        var scale : Double = .nan
        var latitude : Double = .nan
        var longitude : Double = .nan
        PolarStereopgraphic.UPS()
            .pointee
            .Reverse(hemisphere == .northern,
                     easting,
                     northing,
                     &latitude,
                     &longitude,
                     &convergence,
                     &scale)
        self.convergence = convergence
        self.scale = scale
        self.locationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

