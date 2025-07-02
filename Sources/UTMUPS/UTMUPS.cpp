//
//  UTMUPS.cpp
//  GeographicLib
//
//  Created by David Hart on 28/6/2025.
//

#include "UTMUPS.h"
#include <GeographicLib/UTMUPS.hpp>

double UTMUPS::UTMShift() {
    return UTMUPS::UTMShift();
}

int UTMUPS::StandardZone(double latitude, double longitude, int setZone) {
    return GeographicLib::UTMUPS::StandardZone(latitude, longitude, setZone);
}

void UTMUPS::Forward(double lat, double lon,
                     int& zone, bool& northp, double& x, double& y,
                     double& convergence, double& scale,
                     int setzone, bool mgrslimits) {
    try {
        GeographicLib::UTMUPS::Forward(lat, lon, zone, northp, x, y, convergence, scale, setzone, mgrslimits);
    } catch (const std::exception& e) {
        zone = -4;
        x = NAN;
        y = NAN;
        convergence = NAN;
        scale = NAN;
        e.what();
    }
}

void UTMUPS::Reverse(int zone, bool northp, double x, double y,
                    double& lat, double& lon, double& convergence, double& k,
                     bool mgrslimits) {
    try {
        GeographicLib::UTMUPS::Reverse(zone, northp, x, y, lat, lon, convergence, k, mgrslimits);
    } catch (const std::exception& e) {
        lat = NAN;
        lon = NAN;
        convergence = NAN;
        k = NAN;
    }
}

void UTMUPS::Transfer(int zonein, bool northpin, double xin, double yin,
                     int zoneout, bool northpout, double& xout, double& yout,
                      int& zone) {
    try {
        GeographicLib::UTMUPS::Transfer(zonein, northpin, xin, yin, zoneout, northpout, xout, yout, zone);
    } catch (const std::exception& e) {
        xout = NAN;
        yout = NAN;
        zone = -4;
    }
}
