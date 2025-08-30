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
}
