//
//  UtilityTests.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 16/8/2025.
//
import Foundation
import Testing
@testable import Utility
import RealModule

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

@Test func epoch() {
    let date = dateFormatter.date(from: "2025-08-16")!
    #expect(date.fractionalYear.isApproximatelyEqual(to: 2025.6219, absoluteTolerance: 1e-4))
}
