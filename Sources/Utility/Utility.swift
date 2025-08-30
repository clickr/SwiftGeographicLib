//
//  Utility.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 16/8/2025.
//
import Foundation
import GeographicLib

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

public extension Date {
    /// GeographicLib calculation for fractional year
    var fractionalYear : Double {
        return GeographicLib.Utility.fractionalyear(std.string(dateFormatter.string(from: self)))
    }
}
