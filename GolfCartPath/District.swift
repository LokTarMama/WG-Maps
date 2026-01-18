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
    
    func is_valid_point(location: CLLocationCoordinate2D) -> Bool {
        let location_point = MKMapPoint(location)
        let districtRenderer = MKPolygonRenderer(polygon: getPolygon())
        let renderedPoint = districtRenderer.point(for: location_point)
        if !districtRenderer.path.contains(renderedPoint) {
            print("CGPoint was out of range")
            return false
        }
        
        return true
    }
}

