//
//  UTM.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 27/7/2025.
//

import Foundation
import CoreLocation
import GeographicLib
import TransverseMercator
@_exported import GeographicError

//typealias TransverseMercator = GeographicLib.TransverseMercator

public enum UTMError : Error {
    /// Valid zones are in the closed range [1, 60]
    case invalidZone(zone: Int32)
    /// Valid latitudes fall within [-90, 90]
    case illegalLatitude(latitude: Double)
    /// ## Easting Constraint Error
    /// ### Standard UTM
    /// Eastings must be wiithin [0m, 1,000,000m]
    /// ### MGRS
    /// Eastings must be within [100,000m, 900,000m]
    case eastingOutOfBounds(easting: Double)
    /// ## Northing Constraint Error
    /// ### Northern Hemisphere
    /// Northings must be within [-9,100,000m, 9,600,000m]
    /// ### Northern Hemisphere MGRS
    /// Northings must be within [-9,00,000m, 9,500,000m]
    /// ### Southern Hemisphere
    /// Northings must be within [900,000m, 19,600,000m]
    /// ### Southern Hemisphere MGRS
    /// Northings must be within [1000,000m, 19,500,000m]
    case northingOutOfBounds(northing: Double)
}

/**
 Represents a Universal Transverse Mercator (UTM) coordinate, providing methods to convert between latitude/longitude and UTM coordinates.

 UTM is a global map projection system that divides the world into 60 longitudinal zones, each 6° wide, and projects coordinates onto a transverse Mercator projection for each zone. This struct encapsulates all necessary parameters for a single UTM coordinate, including:

 - `zone`: The UTM longitudinal zone (valid range: 1...60)
 - `hemisphere`: The hemisphere of the coordinate (.northern or .southern)
 - `easting`: The easting value in meters within the zone
 - `northing`: The northing value in meters within the zone
 - `convergence`: The meridian convergence at this point, in degrees
 - `scale`: The point scale factor at this location
 - `locationCoordinate2D`: The original CLLocationCoordinate2D for reference

 The `UTM` struct offers:
 - Validation for legal zone, easting, and northing values (with support for both standard and stricter MGRS limits)
 - Conversion from geographic (latitude, longitude) coordinates into UTM, and vice versa
 - Support for direct initialization from UTM parameters or from Core Location coordinates

 Throws errors if any of the zone, easting, or northing parameters are out of bounds.
*/
public struct UTM : UTMUPSCoordinate {
    public static func eastingLegalRange(mgrsLimits: Bool = false) -> ClosedRange<Double> {
        if mgrsLimits {
            let min = minimumUTMEasting + mgrsBuffer
            let max = maximumUTMEasting - mgrsBuffer
            return min...max
        } else {
            return minimumUTMEasting...maximumUTMEasting
        }
    }
    public var zone : Int32
    
    public var hemisphere: Hemisphere
    
    public var easting: Double
    
    public var northing: Double
    
    public var convergence: Double
    
    public var scale: Double
    
    public var locationCoordinate2D: CLLocationCoordinate2D
    
    /// Init with UTM Coordinates
    ///
    /// Valid UTM zones are in the range [1, 60]
    ///
    /// UTM eastings are allowed to be in the range [0km, 1000km], northings are
    /// allowed to be in in [0km, 9600km] for the northern hemisphere and in
    /// [900km, 10000km] for the southern hemisphere.  However UTM northings
    /// can be continued across the equator.  So the actual limits on the
    /// northings are [-9100km, 9600km] for the "northern" hemisphere and
    /// [900km, 19600km] for the "southern" hemisphere.
    ///
    /// UPS eastings and northings are allowed to be in the range [1200km,
    /// 2800km] in the northern hemisphere and in [700km, 3300km] in the
    /// southern hemisphere.
    ///
    /// These ranges are 100km larger than allowed for the conversions to MGRS.
    /// (100km is the maximum extra padding consistent with eastings remaining
    /// non-negative.)  This allows generous overlaps between zones and UTM and
    /// UPS.  If `mgrslimits = true`, then all the ranges are shrunk by 100km
    /// so that they agree with the stricter MGRS ranges.  No checks are
    /// performed besides these (e.g., to limit the distance outside the
    /// standard zone boundaries).
    /// - Throws: `.invalidZone` if zone not in the range [1, 60]
    /// - Throws: `.eastingOutOfBounds` if easting not in [0m, 1,000,000m], [100,000m, 900,000m] with `mgrsLimits == true`
    /// - Throws: `.northingOutOfBounds` **Northern Hemisphere** northings not in [-9,100,000m, 9,600,000m], [-9,000,000m, 9,500,000m] `mgrsLimits == true`
    /// - Throws: `.northingOutOfBounds` **Southern Hemisphere** northings not in [900,000m, 19,600,000m], [1,000,000m, 19,500,000m] `mgrsLimits == true`
    public init(hemisphere: Hemisphere, zone: Int32, easting: Double, northing: Double, mgrsLimits: Bool = false) throws(UTMError) {
        guard zone > 0 && zone <= 60 else {
            throw .invalidZone(zone: zone)
        }
        let slop = mgrsLimits ? mgrsBuffer : 0
        guard easting >= slop && easting <= maximumUTMEasting - slop else {
            throw .eastingOutOfBounds(easting: easting)
        }
       
        if hemisphere == .northern {
            guard northing >= minimumNorthernUTMNorthing + slop && northing <= maximumNorthernUTMNorthing - slop else {
                throw .northingOutOfBounds(northing: northing)
            }
        } else {
            guard northing >= minimumSouthernUTMNorthing + slop && northing <= maximumSouthernUTMNorthing - slop else {
                throw .northingOutOfBounds(northing: northing)
            }
        }
        self.easting = easting
        self.northing = northing
        self.zone = zone
        self.hemisphere = hemisphere

        let lon0 = centralMeridian(zone: zone)
        let x = easting - utmFalseEasting
        let y = hemisphere == .northern ? northing : northing - utmNorthShift
        
        let reverseTM = TransverseMercator.UTM.reverse(centralMeridian: lon0, x: x, y: y)
        
        self.convergence = reverseTM.convergence
        self.scale = reverseTM.scale
        self.locationCoordinate2D
        = reverseTM.coordinate
    }
    
    /// Init with latitude and longitude
    ///
    /// UTM eastings are allowed to be in the range [0km, 1000km], northings are
    /// allowed to be in in [0km, 9600km] for the northern hemisphere and in
    /// [900km, 10000km] for the southern hemisphere.  However UTM northings
    /// can be continued across the equator.  So the actual limits on the
    /// northings are [-9100km, 9600km] for the "northern" hemisphere and
    /// [900km, 19600km] for the "southern" hemisphere.
    ///
    /// UPS eastings and northings are allowed to be in the range [1200km,
    /// 2800km] in the northern hemisphere and in [700km, 3300km] in the
    /// southern hemisphere.
    ///
    /// These ranges are 100km larger than allowed for the conversions to MGRS.
    /// (100km is the maximum extra padding consistent with eastings remaining
    /// non-negative.)  This allows generous overlaps between zones and UTM and
    /// UPS.  If `mgrslimits = true`, then all the ranges are shrunk by 100km
    /// so that they agree with the stricter MGRS ranges.  No checks are
    /// performed besides these (e.g., to limit the distance outside the
    /// standard zone boundaries).
    /// - Throws: `CoordinateError.eastingOutOfBounds` if self.easting not in [0m, 1,000,000m], [100,000m, 900,000m] with `mgrsLimits == true`
    /// - Throws: `CoordinateError.northingOutOfBounds` **Northern Hemisphere** self.northing not in [-9,100,000m, 9,600,000m], [-9,000,000m, 9,500,000m] `mgrsLimits == true`
    /// - Throws: `CoordinateError.northingOutOfBounds` **Southern Hemisphere** self.northing not in [900,000m, 19,600,000m], [1,000,000m, 19,500,000m] `mgrsLimits == true`
    /// - Throws:  `CoordinateError.illegalLatitude` if latitude not in -90&deg;... 90&deg;
    public init(latitude: Double, longitude: Double, zoneSpec: ZoneSpec = .utm, mgrsLimits: Bool = false) throws {
        
        // This will throw if latitude is not legal
        let standardZone = try UTM.standardZone(latitude: latitude, longitude: longitude, zoneSpec: zoneSpec)
        let lon0 = centralMeridian(zone: standardZone)
        
        let forwardTM = try TransverseMercator.UTM.forward(centralMeridian: lon0, latitude: latitude, longitude: longitude)

        easting = forwardTM.easting + utmFalseEasting
        northing = forwardTM.northing + (latitude < 0 ? utmNorthShift : 0)
        let slop = mgrsLimits ? mgrsBuffer : 0
        guard easting >= slop && easting <= maximumUTMEasting - slop else {
            throw CoordinateError.eastingOutOfBounds(easting: easting)
        }
        scale = forwardTM.scale
        convergence = forwardTM.convergence
        locationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        hemisphere = latitude >= 0 ? .northern : .southern
        zone = standardZone
        if hemisphere == .northern {
            guard northing >= minimumNorthernUTMNorthing + slop else {
                throw CoordinateError.northingOutOfBounds(northing: northing)
            }
        } else {
            guard northing >= minimumSouthernUTMNorthing + slop && northing <= maximumSouthernUTMNorthing - slop else {
                throw CoordinateError.northingOutOfBounds(northing: northing)
            }
        }
        if easting < slop || easting > maximumUTMEasting - slop {
            throw CoordinateError.eastingOutOfBounds(easting: easting)
        }
    }

    /**
     Initializes a UTM coordinate from a `CLLocationCoordinate2D` value (latitude and longitude).

     This convenience initializer uses the latitude and longitude from a Core Location coordinate to compute the corresponding UTM zone, easting, northing, and other properties. It routes the conversion through the dedicated geographic initializer.

     - Parameters:
        - coordinate: The Core Location coordinate containing latitude and longitude (in degrees).
        - zoneSpec: (Optional) Controls standard or special zone assignment (default is `.utm`).
        - mgrsLimits: (Optional) If true, applies stricter MGRS easting/northing limits.

     - Throws: `CoordinateError.eastingOutOfBounds`, `CoordinateError.northingOutOfBounds`, or `CoordinateError.illegalLatitude` if the coordinate is invalid or out of UTM bounds.
    */
    public init(coordinate: CLLocationCoordinate2D, zoneSpec: ZoneSpec = .utm, mgrsLimits: Bool = false) throws {
        try self.init(latitude: coordinate.latitude, longitude: coordinate.longitude, zoneSpec: zoneSpec, mgrsLimits: mgrsLimits)
    }
}

