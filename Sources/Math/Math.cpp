//
//  Math.cpp
//  SwiftGeographicLib
//
//  Created by David Hart on 2/7/2025.
//

#include "Math.hpp"
#include <GeographicLib/Math.hpp>

double Math::AngDiff(double a1, double a2) {
    return GeographicLib::Math::AngDiff(a1, a2);
}
