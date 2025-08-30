//
//  Utilities.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 27/7/2025.
//

import Foundation
import GeographicLib
import CoreLocation
@_exported import GeographicError
/// The Central Meridian for a given UTM Zone
///
/// - Parameters:
///     - zone: legal UTM zones are within [1, 60]
///
///  No checks are performed to verify parameter validity
public func centralMeridian(zone: Int32) -> Double {
    return Double(6 * zone - 183)
}

public extension UTM {
    /// The Standard Zone
    /// - Parameters:
    ///     - latitude: location Latitude
    ///     - longitude: location Longitude
    ///     - zoneSpec: ```ZoneSpec```
    static func standardZone(latitude: Double, longitude: Double, zoneSpec: ZoneSpec = .utm) throws -> Int32 {
        guard latitude >= -90 && latitude <= 90 else {
            throw CoordinateError.illegalLatitude(latitude: latitude)
        }
        return GeographicLib.UTMUPS.StandardZone(latitude, longitude, zoneSpec.rawValue)
    }
}


