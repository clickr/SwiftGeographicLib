//
//  CLLocationCoordinate2D+UTMUPS.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 24/8/2025.
//

import CoreLocation
import GeographicLib
@_exported import GeographicError

extension CLLocationCoordinate2D {
    
    /// Get the default UTM or UPS coordinate
    ///
    /// In principle there is a default UTM or UPS coordinate for every location on the globe, however `CLLocationCoordinate2D`
    /// can be created with latitudes outside of -90&deg;...90&deg; which would result in an error in the C++ code which is unknown
    /// to the swift compiler so we will catch that here.
    ///
    /// - Throws: `CoordinateError.illegalLatitude` if latitude outside of -90&deg;...90&deg;
    public func UTMUPSCoordinate() throws -> UTMUPSCoordinate {
        guard latitude <= 90 && latitude >= -90 else {
            throw CoordinateError.illegalLatitude(latitude: latitude)
        }
        let zone = GeographicLib.UTMUPS.StandardZone(latitude, longitude)
        if zone == 0 {
            return try UPS(latitude: latitude, longitude: longitude)
        } else {
            return try UTMUPS.UTM(latitude: latitude, longitude: longitude)
        }
    }
    
    public func UTM(zoneSpec: ZoneSpec = .utm) throws -> UTM {
        return try UTMUPS.UTM(latitude: latitude, longitude: longitude, zoneSpec: zoneSpec)
    }
}
