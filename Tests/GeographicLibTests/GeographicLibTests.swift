import Testing
@testable import GeographicLib
import RealModule

func centralMeridian(zone: Int32) -> Double {
    return Double(6 * zone - 183)
}

typealias real = GeographicLib.Math.real
typealias Math = GeographicLib.Math

public enum ZoneSpec : OptionSet {
    public var rawValue: Int32 {
        switch self {
        case .invalid:
            return -4
        case .match:
            return -3
        case .utm:
            return -2
        case .standard:
            return -1
        case .ups:
            return 0
        case .manual(zone: let zone):
            return zone
        }
    }
    
    
    public typealias RawValue = Int32
    public init(rawValue: Int32) {
        if rawValue > 0 && rawValue <= 60 {
            self = .manual(zone: rawValue)
        }
        switch rawValue {
        case -3:
            self = .match
        case -2:
            self = .utm
        case -1:
            self = .standard
        case 0:
            self = .ups
        default:
            self = .invalid
        }
    }
    
    case invalid
    case match
    case utm
    case standard
    case ups
    case manual(zone: Int32)
}

let falseEasting : Double = 5e5
let northShift : Double = 1e7

func latitudeBand(latitude: Double) -> Int32 {
    let ilat = Int32(floor(latitude))
    return max(-10, min(9, (ilat + 80)/8 - 10))
}
func standardZone(latitude: Double, longitude: Double, zoneSpec: ZoneSpec = .standard) -> Int32 {
    switch zoneSpec {
    case .invalid:
        return -4
    case .manual(let zone):
        return zone
    default:
        if zoneSpec == .utm || (latitude >= -80 && latitude < 84) {
            var ilon = Int32(floor(GeographicLib.Math.AngNormalize(longitude)))
            if ilon == 180 {
                ilon = -180
            }
            var zone = (ilon + 186)/6;
            let band : Int32 = latitudeBand(latitude: Double(latitude))
            if band == 7 && zone == 31 && ilon >= 3 {
                zone = 32
            } else if band == 9 && ilon >= 0 && ilon < 42 {
                zone = 2 * ((ilon + 183)/12) + 1
            }
            return zone
        } else {
            return 0;
        }
        
    }
}

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    var x : real = .nan
    var y : real = .nan
    var gamma : real = .nan
    var k : real = .nan
    let latitude : Double = -31.94028333
    let longitude : Double = 115.96695
    let standardZone = standardZone(latitude: latitude, longitude: longitude)
    let sz = GeographicLib.UTMUPS.StandardZone(latitude, longitude)
    #expect(sz == 50)
    #expect(standardZone == 50)
    let lon0 = centralMeridian(zone: standardZone)
    #expect(lon0 == 117)
    GeographicLib.TransverseMercator.UTM().pointee.Forward(lon0, latitude, longitude, &x, &y, &gamma, &k)
    x += falseEasting
    y += northShift
    #expect(x.isFinite)
    #expect(y.isFinite)
    #expect(x.isApproximatelyEqual(to: 402357.369285629, absoluteTolerance: 1e-9))
    
    #expect(y.isApproximatelyEqual(to: 6465717.701277924, absoluteTolerance: 1e-9))
    #expect(gamma.isApproximatelyEqual(to: 0.5465629794442, absoluteTolerance: 1e-9))
    #expect(k.isApproximatelyEqual(to: 0.999717579467930, absoluteTolerance: 1e-9))
}
