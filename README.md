# SwiftGeographicLib

## Introduction

SwiftGeographicLib is intended to provide a swift interface to the C++ GeographicLib library

## Current Implementation (Incomplete)

### GeoCoords (Incomplete)

Conversion between geographic coordinates

This struct stores a geographic position which may be set via the
constructors or Reset via
- latitude and longitude
- UTM or UPS coordinates

#### TODO

Add Transfer Coordinates Between Hemispheres

```Swift
import GeoCoords

let utm = try GeoCoords(zone: 50, northp: false, x: 402357.369285629, y: 6465717.701277924)

let geoInit = try GeoCoords(latitude: -31.94028333, longitude: 115.96695)

let geoInitWithZone = try GeoCoords(latitude: -31.94028333, longitude: 115.96695, setZone: 49)

```
