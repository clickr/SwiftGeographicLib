//
//  GeoConstants.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 14/8/2025.
//

public struct GeoConstants {
    public static let WGS84_equatorialRadius : Double = 6378137.0
    public static let WGS84_flattening : Double = 1.0 / (298257223563.0 / 1000000000.0)
    public static let WGS84_AngularVelocity : Double = 7292115 / (1000000 * 100000)
    public static let WGS84_GravitationalConstant : Double = 3986004 * 100000000 + 41800000
    public static let UTM_CentralScaleFactor : Double = 9996 / 10000
    public static let UPS_CentralScaleFactor : Double = 9994 / 10000
}
