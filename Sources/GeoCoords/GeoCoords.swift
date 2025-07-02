//
//  GeoCoords.swift
//  GeographicLib
//
//  Created by David Hart on 29/6/2025.
//

import UTMUPS
import Foundation

public enum GeoHemisphere {
    case northern
    case southern
}

public enum GeographicError: Error {
    case zoneOutOfRange
    case invalidZoneSpecification
    case utmOutOfRange
    case upsOutOfRange
    case latitudeTooLowForUPS
    case latitudeTooHighForUPS
    case latitudeLongitudeIllegalForUTMZone
    case invalidLatitude
    case cppException
    case none
    func throwIfNeeded() throws {
        switch self {
        case .none:
            break
        default:
            throw self
        }
    }
}

public func centralMeridian(zone: Int32) -> Double {
    return Double(6 * zone - 183)
}

/*
    * UTM eastings are allowed to be in the range [0km, 1000km], northings are
    * allowed to be in in [0km, 9600km] for the northern hemisphere and in
    * [900km, 10000km] for the southern hemisphere.  However UTM northings
    * can be continued across the equator.  So the actual limits on the
    * northings are [-9100km, 9600km] for the "northern" hemisphere and
    * [900km, 19600km] for the "southern" hemisphere.
    * These ranges are 100km larger than allowed for the conversions to MGRS.
    * (100km is the maximum extra padding consistent with eastings remaining
    * non-negative.)  This allows generous overlaps between zones and UTM and
    * UPS.  If \e mgrslimits = true, then all the ranges are shrunk by 100km
    * so that they agree with the stricter MGRS ranges.  No checks are
    * performed besides these (e.g., to limit the distance outside the
    * standard zone boundaries).
    *
    * UPS eastings and northings are allowed to be in the range [1200km,
    * 2800km] in the northern hemisphere and in [700km, 3300km] in the
    * southern hemisphere.
    *

 */
func utmupsError(zone: Int32, northp: Bool, x: Double, y: Double, mgrslimits: Bool = false) -> GeographicError {
    guard zone >= 0 && zone <= 60 else {
        return .zoneOutOfRange
    }
    if northp {
        if zone == 0 {
            let min = 1200000.0 + (mgrslimits ? 100000.0 : 0)
            let max = 2800000.0 - (mgrslimits ? 100000.0 : 0)
            if x < min || x > max || y < min || y > max {
                return GeographicError.upsOutOfRange
            }
        } else {
            let xMin : Double = 0
            let xMax : Double = 1000 * 1000
            let yMin : Double = -9100 * 1000
            let yMax : Double = 9600 * 1000
            if x < xMin || x > xMax || y < yMin || y > yMax {
                return GeographicError.utmOutOfRange
            }
        }
    } else {
        if zone == 0 {
            let min = 700000.0 + (mgrslimits ? 100000.0 : 0)
            let max = 3300000.0 - (mgrslimits ? 100000.0 : 0)
            if x < min || x > max || y < min || y > max {
                return GeographicError.upsOutOfRange
            }
        } else {
            let xMin : Double = 0
            let xMax : Double = 1000 * 1000
            let yMin : Double = 900 * 1000
            let yMax : Double = 19600 * 1000
            if x < xMin || x > xMax || y < yMin || y > yMax {
                return GeographicError.utmOutOfRange
            }
        }
    }
    return .none
}

public enum CoordinateSystem {
    case utm(Bool)
    case ups(Bool)
}

 /// Conversion between geographic coordinates
 ///
 /// This struct stores a geographic position which may be set via the
 /// constructors or Reset via
 /// - latitude and longitude
 /// - UTM or UPS coordinates
 ///
 /// The state consists of the latitude and longitude and the supplied UTM or
 /// UPS coordinates (possibly derived from the MGRS coordinates).  If latitude
 /// and longitude were given then the UTM/UPS coordinates follows the standard
 /// conventions.
public struct GeoCoords : Sendable {
    public private(set) var latitude: Double = .nan
    public private(set) var longitude: Double = .nan
    public private(set) var x : Double = .nan
    public private(set) var y : Double = .nan
    public private(set) var zone : Int32
    public private(set) var northp : Bool
    public private(set) var convergence : Double
    public private(set) var scale : Double
    
    public init(latitude: Double, longitude: Double, setZone : Int32, mgrslimits : Bool = false) throws {
        guard latitude >= -90 && latitude <= 90 else {
            throw GeographicError.invalidLatitude
        }
        self.latitude = latitude
        self.longitude = longitude
        x = .nan
        y = .nan
        zone = -4
        northp = false
        convergence = .nan
        scale = .nan
        UTMUPS.Forward(latitude, longitude, &zone, &northp, &x, &y, &convergence, &scale, setZone, mgrslimits)
        if x.isNaN {
            if setZone == 0, 70.0 < Swift.abs(latitude) {
                if latitude > -70 {
                    throw GeographicError.latitudeTooHighForUPS
                } else if latitude < 70 {
                    throw GeographicError.latitudeTooLowForUPS
                }
            }
            throw GeographicError.latitudeLongitudeIllegalForUTMZone
        }
    }
    
    public init(latitude: Double, longitude: Double) throws {
        try self.init(latitude: latitude, longitude: longitude, setZone: -1)
    }
    
    public init(zone: Int32, northp: Bool, x: Double, y: Double, mgrslimits : Bool = false) throws {
        latitude = .nan
        longitude = .nan
        self.x = x
        self.y = y
        self.zone = zone
        self.northp = northp
        convergence = .nan
        scale = .nan
        UTMUPS.Reverse(zone, northp, x, y, &latitude, &longitude, &convergence, &scale, mgrslimits)
        if latitude.isNaN {
            try utmupsError(zone: zone, northp: northp, x: x, y: y).throwIfNeeded()
            throw GeographicError.cppException
        }
    }
}
