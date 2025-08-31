//
//  MagneticModel.swift
//  SwiftGeographicLib
//
//  Created by David Hart on 16/8/2025.
//

import Foundation
@preconcurrency import GeographicLib
import CoreLocation
@_exported import GeographicError

public enum MagneticModelError: Error {
    case modelNotFound
    case outsideDateRange(fractionalDate: Double)
    case outsideHeightRange(height: Double)
}

extension String {
    var cppString: std.string {
        return std.string(self)
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

/// \brief Model of the earth's magnetic field
///
/// Evaluate the earth's magnetic field according to a model.  At present only
/// internal magnetic fields are handled.  These are due to the earth's code
/// and crust; these vary slowly (over many years).  Excluded are the effects
/// of currents in the ionosphere and magnetosphere which have daily and
/// annual variations.
///
/// See \ref magnetic for details of how to install the magnetic models and
/// the data format.
///
/// See
/// - General information:
///   - [](http://geomag.org/models/index.html)
/// - WMM2010:
///   - [](https://ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml)
///   - [](https://ngdc.noaa.gov/geomag/WMM/data/WMM2010/WMM2010COF.zip)
/// - WMM2015 (deprecated):
///   - [](https://ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml)
///   - [](https://ngdc.noaa.gov/geomag/WMM/data/WMM2015/WMM2015COF.zip)
/// - WMM2015V2:
///   - [](https://ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml)
///   - [](https://ngdc.noaa.gov/geomag/WMM/data/WMM2015/WMM2015v2COF.zip)
/// - WMM2020:
///   - [](https://ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml)
///   - [](https://ngdc.noaa.gov/geomag/WMM/data/WMM2020/WMM2020COF.zip)
/// - WMM2025:
///   - [](https://www.ncei.noaa.gov/products/world-magnetic-model)
/// - WMMHR2025:
///   - [](https://www.ncei.noaa.gov/products/world-magnetic-model-high-resolution)
/// - IGRF11:
///   - [](https://ngdc.noaa.gov/IAGA/vmod/igrf.html)
///   - [](https://ngdc.noaa.gov/IAGA/vmod/igrf11coeffs.txt)
///   - [](https://ngdc.noaa.gov/IAGA/vmod/geomag70_linux.tar.gz)
/// - EMM2010:
///   - [](https://ngdc.noaa.gov/geomag/EMM/index.html)
///   - [](https://ngdc.noaa.gov/geomag/EMM/data/geomag/EMM2010_Sph_Windows_Linux.zip)
/// - EMM2015:
///   - [](https://ngdc.noaa.gov/geomag/EMM/index.html)
///   - [](https://www.ngdc.noaa.gov/geomag/EMM/data/geomag/EMM2015_Sph_Linux.zip)
/// - EMM2017:
///   - [](https://ngdc.noaa.gov/geomag/EMM/index.html)
///   - [](https://www.ngdc.noaa.gov/geomag/EMM/data/geomag/EMM2017_Sph_Linux.zip)
///
/// [MagneticField](https://geographiclib.sourceforge.io/html/MagneticField.1.html)
///  is a command-line utility providing access to the functionality of MagneticModel and MagneticCircle.
public final class MagneticModel : Sendable {
    /// Enhanced Magnetic Model 2010
    ///
    /// [](https://ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml)
    public static let emm2010   : MagneticModel = try! MagneticModel(name: "emm2010")
    /// Enhanced Magnetic Model 2015
    ///
    /// [](https://ngdc.noaa.gov/geomag/WMM/DoDWMM.shtml)
    public static let emm2015   : MagneticModel = try! MagneticModel(name: "emm2015")
    /// Enhanced Magnetic Model 2017
    public static let emm2017   : MagneticModel = try! MagneticModel(name: "emm2017")
    /// International Geomagnetic Reference Field - 11th Generation
    ///
    /// [](https://ngdc.noaa.gov/IAGA/vmod/igrf.html)
    public static let igrf11    : MagneticModel = try! MagneticModel(name: "igrf11")
    /// International Geomagnetic Reference Field - 12th Generation
    ///
    /// [](https://ngdc.noaa.gov/IAGA/vmod/igrf.html)
    public static let igrf12    : MagneticModel = try! MagneticModel(name: "igrf12")
    /// International Geomagnetic Reference Field - 13th Generation
    ///
    /// [](https://ngdc.noaa.gov/IAGA/vmod/igrf.html)
    public static let igrf13    : MagneticModel = try! MagneticModel(name: "igrf13")
    /// International Geomagnetic Reference Field - 14th Generation
    ///
    /// [](https://ngdc.noaa.gov/IAGA/vmod/igrf.html)
    public static let igrf14    : MagneticModel = try! MagneticModel(name: "igrf14")
    /// World Magnetic Model 2010
    ///
    /// /// [](https://www.ncei.noaa.gov/products/world-magnetic-model)
    public static let wmm2010   : MagneticModel = try! MagneticModel(name: "wmm2010")
    /// World Magnetic Model 2015
    ///
    /// /// [](https://www.ncei.noaa.gov/products/world-magnetic-model)
    public static let wmm2015   : MagneticModel = try! MagneticModel(name: "wmm2015")
    /// World Magnetic Model 2015 Version 2
    ///
    /// /// [](https://www.ncei.noaa.gov/products/world-magnetic-model)
    public static let wmm2015v2 : MagneticModel = try! MagneticModel(name: "wmm2015v2")
    /// World Magnetic Model 2020
    ///
    /// /// [](https://www.ncei.noaa.gov/products/world-magnetic-model)
    public static let wmm2020   : MagneticModel = try! MagneticModel(name: "wmm2020")
    /// World Magnetic Model 2025
    ///
    /// [](https://www.ncei.noaa.gov/products/world-magnetic-model)
    public static let wmm2025   : MagneticModel = try! MagneticModel(name: "wmm2025")
    /// World Magnetic Model High Resolution 2025
    ///
    /// [](https://www.ncei.noaa.gov/products/world-magnetic-model-high-resolution)
    public static let wmmhr2025 : MagneticModel = try! MagneticModel(name: "wmmhr2025")
    
    
    private let model : GeographicLib.MagneticModel
    
    /// Declination, Inclination, Horizontal Field, Total Field given by the appropriate World Magnetic Model
    ///
    /// The World Magnetic Model (WMM) is the standard model for navigation, attitude, and heading referencing systems that use the  geomagnetic field.
    ///
    /// ## Limitations
    /// The WMM and the charts produced from this model only describe the long-wavelength portion of Earth's internal magnetic field, which is primarily generated in Earth's fluid outer core. The effects of the Earth's crust and upper mantle, ionosphere, and magnetosphere are not represented in the WMM. This means that a magnetic sensor such as a compass or magnetometer may observe spatial and temporal magnetic anomalies when referenced to the WMM. Some local, regional, and temporal magnetic declination anomalies can exceed 10 degrees. Anomalies of this magnitude are not common but they do exist. Declination anomalies of the order of 3 or 4 degrees are not uncommon but are usually of small spatial extent.
    ///
    /// - Throws: `MagneticModelError.outsideDateRange` if date is outside models parameters 2010..<2030
    public class func WorldMagneticModel(date: Date = Date(), coordinate: CLLocationCoordinate2D, height: Double = 0) throws -> (declination: Double, inclination: Double, horizontalField: Double, totalField: Double) {
        let dateString = dateFormatter.string(from: date).cppString
        let fractionalYear : Double = GeographicLib.Utility.fractionalyear(dateString)
        guard fractionalYear >= 2010 && fractionalYear < 2030 else {
            throw MagneticModelError.outsideDateRange(fractionalDate: fractionalYear)
        }
        if fractionalYear < 2015 {
            return try MagneticModel.emm2010.modelFieldComponents(date: date, coordinate: coordinate, height: height)
        }
        if fractionalYear < 2020 {
            return try MagneticModel.wmm2015v2.modelFieldComponents(date: date, coordinate: coordinate, height: height)
        }
        if fractionalYear < 2025 {
            return try MagneticModel.wmm2020.modelFieldComponents(date: date, coordinate: coordinate, height: height)
        }
        return try MagneticModel.wmmhr2025.modelFieldComponents(date: date, coordinate: coordinate, height: height)
    }
    /// Declination, Inclination, Horizontal Field, Total Field given by the appropriate EnhancedMagneticModel
    ///
    /// - Throws: `MagneticModelError.outsideDateRange` if date is outside models parameters 2000..<2022
    public class func EnhancedMagneticModel(date: Date, coordinate: CLLocationCoordinate2D, height: Double = 0) throws -> (declination: Double, inclination: Double, horizontalField: Double, totalField: Double) {
        let dateString = dateFormatter.string(from: date).cppString
        let fractionalYear : Double = GeographicLib.Utility.fractionalyear(dateString)
        guard fractionalYear >= 2000 && fractionalYear < 2022 else {
            throw MagneticModelError.outsideDateRange(fractionalDate: fractionalYear)
        }
        if fractionalYear < 2010 {
            return try MagneticModel.emm2015.modelFieldComponents(date: date, coordinate: coordinate, height: height)
        }
        
        if fractionalYear < 2015 {
            return try MagneticModel.emm2010.modelFieldComponents(date: date, coordinate: coordinate, height: height)
        }
        
        return try MagneticModel.emm2017.modelFieldComponents(date: date, coordinate: coordinate, height: height)
    }
    
    /// Supply your own model at your own risk
    ///
    /// > Warning: Only checks are for the existance of the appropriate model files (<name>.wmm, <name>.wmm.cof). Files with invalid formats
    /// will cause a C++ error to be thrown that cannot be handled by swift.
    ///
    /// Information about the file formats can be obtained at
    /// [](https://geographiclib.sourceforge.io/C++/doc/magnetic.html#magneticformat)
    ///
    /// - Throws: `MagneticModelError.modelNotFound`
    ///  if [name].wmm or [name].wmm.cof don't exist in the supplied directory.
    public class func unsafeInit(name: String, directoryURL: URL) throws -> MagneticModel {
        return try .init(name: name, directoryURL: directoryURL)
    }
    
    init(name: String, directoryURL: URL) throws {
        guard FileManager.default.fileExists(atPath: "\(directoryURL.path)/\(name).wmm"),
              FileManager.default.fileExists(atPath: "\(directoryURL.path)/\(name).wmm.cof")
        else {
            throw MagneticModelError.modelNotFound
        }
        model = GeographicLib.MagneticModel(std.string(name),
                                            std.string(directoryURL.path),
                                            GeographicLib.Geocentric.WGS84().pointee, -1, -1)
    }
    
    convenience init(name: String) throws {
        guard let directoryURL = Bundle.module.url(forResource: name, withExtension: "wmm")?.deletingLastPathComponent() else {
            throw MagneticModelError.modelNotFound
        }
        try self.init(name: name, directoryURL: directoryURL)
    }
    
    /// Magnetic Field Componens, Bx, By, Bz, for a date and location
    ///
    /// - Throws: `CoordinateError.illegalLatitude` if coordinate.latitude outside of -90&deg;...90&deg;
    /// - Throws: `MagneticModelError.outsideHeightRange` if outside model height range
    /// - Throws: `MagneticModelError.outsideDateRange` if outside of model date range
    public func modelField(date: Date, coordinate: CLLocationCoordinate2D, height: Double = 0) throws -> (bx: Double, by: Double, bz: Double) {
        guard coordinate.latitude >= -90 && coordinate.latitude <= 90 else {
            throw CoordinateError.illegalLatitude(latitude: coordinate.latitude)
        }
        guard height >= model.MinHeight() && height <= model.MaxHeight() else {
            throw MagneticModelError.outsideHeightRange(height: height)
        }
        let dateString = dateFormatter.string(from: date).cppString
        let fy : Double = GeographicLib.Utility.fractionalyear(dateString)
        guard fy >= model.MinTime() && fy < model.MaxTime() else {
            throw MagneticModelError.outsideDateRange(fractionalDate: fy)
        }
        
        var bx : Double = .nan
        var by : Double = .nan
        var bz : Double = .nan
        
        model.callAsFunction(fy,
                             coordinate.latitude,
                             coordinate.longitude,
                             height, &bx, &by, &bz)
        return (bx: bx, by: by, bz: bz)
    }
    /// Declination, Inclination, Horizontal Field, and Total Field for a date, coordinate, and height
    ///
    /// - Throws: `CoordinateError.illegalLatitude` if coordinate.latitude outside of -90&deg;...90&deg;
    /// - Throws: `MagneticModelError.outsideHeightRange` if outside model height range
    /// - Throws: `MagneticModelError.outsideDateRange` if outside of model date range
    public func modelFieldComponents(date: Date, coordinate: CLLocationCoordinate2D, height: Double = 0) throws -> (declination: Double, inclination: Double, horizontalField: Double, totalField: Double) {
        
        let field = try modelField(date: date, coordinate: coordinate, height: height)
        
        var h : Double = .nan
        var f : Double = .nan
        var d : Double = .nan
        var i : Double = .nan
        GeographicLib.MagneticModel.FieldComponents(field.bx, field.by, field.bz, &h, &f, &d, &i)
        return (declination: d, inclination: i, horizontalField: h, totalField: f)
    }
    /// Maximum height for model
    public var maxHeight: Double { model.MaxHeight() }
    /// Minimum height for model
    public var minHeight: Double { model.MinHeight() }
    /// Minimum fractional year for model (e.g. 2025.0)
    public var minTime: Double { model.MinTime() }
    /// Maximum fractional year for model (e.g. 2029.9)
    public var maxTime: Double { model.MaxTime() }
}
