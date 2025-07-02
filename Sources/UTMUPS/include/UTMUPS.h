//
//  Header.h
//  GeographicLib
//
//  Created by David Hart on 28/6/2025.
//

//#ifndef UTMUPS_h
//#define UTMUPS_h

#include <stdio.h>

class UTMUPS {
public:
    enum zonespec {
      /**
       * The smallest pseudo-zone number.
       **********************************************************************/
      MINPSEUDOZONE = -4,
      /**
       * A marker for an undefined or invalid zone.  Equivalent to NaN.
       **********************************************************************/
      INVALID = -4,
      /**
       * If a coordinate already include zone information (e.g., it is an MGRS
       * coordinate), use that, otherwise apply the UTMUPS::STANDARD rules.
       **********************************************************************/
      MATCH = -3,
      /**
       * Apply the standard rules for UTM zone assigment extending the UTM zone
       * to each pole to give a zone number in [1, 60].  For example, use UTM
       * zone 38 for longitude in [42&deg;, 48&deg;).  The rules include the
       * Norway and Svalbard exceptions.
       **********************************************************************/
      UTM = -2,
      /**
       * Apply the standard rules for zone assignment to give a zone number in
       * [0, 60].  If the latitude is not in [&minus;80&deg;, 84&deg;), then
       * use UTMUPS::UPS = 0, otherwise apply the rules for UTMUPS::UTM.  The
       * tests on latitudes and longitudes are all closed on the lower end open
       * on the upper.  Thus for UTM zone 38, latitude is in [&minus;80&deg;,
       * 84&deg;) and longitude is in [42&deg;, 48&deg;).
       **********************************************************************/
      STANDARD = -1,
      /**
       * The largest pseudo-zone number.
       **********************************************************************/
      MAXPSEUDOZONE = -1,
      /**
       * The smallest physical zone number.
       **********************************************************************/
      MINZONE = 0,
      /**
       * The zone number used for UPS
       **********************************************************************/
      UPS = 0,
      /**
       * The smallest UTM zone number.
       **********************************************************************/
      MINUTMZONE = 1,
      /**
       * The largest UTM zone number.
       **********************************************************************/
      MAXUTMZONE = 60,
      /**
       * The largest physical zone number.
       **********************************************************************/
      MAXZONE = 60,
    };
    static int StandardZone(double latitude,
                            double longitude,
                            int setzone = UTMUPS::STANDARD);
    static double UTMShift();
    static void Reverse(int zone,
                        bool northp,
                        double x,
                        double y,
                        double& latitude,
                        double& longitude,
                        double& convergence,
                        double& k,
                        bool mgrslimits = false);
    static void Forward(double latitude,
                        double longitude,
                        int& zone,
                        bool& northp,
                        double& x,
                        double& y,
                        double& convergence,
                        double& scale,
                        int setzone = UTMUPS::STANDARD,
                        bool mgrslimits = false);
    static void Transfer(int zonein,
                         bool northpin,
                         double xin,
                         double yin,
                         int zoneout,
                         bool northpout,
                         double& xout,
                         double& yout,
                         int& zone);
};


//#endif /* UTMUPS_h */
