//
//  District.swift
//  GolfCartPath
//
//  Created by Andrea Adams on 1/17/26.
//

import MapKit

struct WinterGarden {
    func getPolygon() -> MKPolygon {
        let points: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 28.59564, longitude: -81.55874), // north
            CLLocationCoordinate2D(latitude: 28.55126, longitude: -81.55874), // east
            CLLocationCoordinate2D(latitude: 28.55126, longitude: -81.61621), // sount
            CLLocationCoordinate2D(latitude: 28.59564, longitude: -81.61621)  // west
        ]
        return MKPolygon(coordinates: points, count: points.count)
    }
}

