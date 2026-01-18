//
//  District.swift
//  GolfCartPath
//
//  Created by Andrea Adams on 1/17/26.
//

import MapKit

struct WinterGarden {
    private let wg_calculated_coords_dict: [String: [(Double, Double)]] = [
        "Downtown / central grid (Plant St / Dillard / core)": [
            (28.5728, -81.6465),
            (28.5728, -81.6340),
            (28.5652, -81.6340),
            (28.5652, -81.6465),
            (28.5728, -81.6465)
        ],
        "West / south-west neighborhoods (toward the larger western residential blocks)": [
            (28.5685, -81.6735),
            (28.5685, -81.6545),
            (28.5550, -81.6545),
            (28.5550, -81.6735),
            (28.5685, -81.6735)
        ],
        "Far-west lakeside edge / northwest corridors (ok to include lake)": [
            (28.5885, -81.6755),
            (28.5885, -81.6575),
            (28.5730, -81.6575),
            (28.5730, -81.6755),
            (28.5885, -81.6755)
        ],
        "North-central neighborhoods (between lake edge and downtown)": [
            (28.5880, -81.6515),
            (28.5880, -81.6325),
            (28.5735, -81.6325),
            (28.5735, -81.6515),
            (28.5880, -81.6515)
        ],
        "East-of-downtown corridor band (connectors heading east)": [
            (28.5750, -81.6325),
            (28.5750, -81.6135),
            (28.5640, -81.6135),
            (28.5640, -81.6325),
            (28.5750, -81.6325)
        ],
        "North-east neighborhoods (large looping residential area)": [
            (28.5885, -81.6325),
            (28.5885, -81.6060),
            (28.5720, -81.6060),
            (28.5720, -81.6325),
            (28.5885, -81.6325)
        ],
        "South / south-central neighborhoods (below downtown grid)": [
            (28.5655, -81.6465),
            (28.5655, -81.6280),
            (28.5525, -81.6280),
            (28.5525, -81.6465),
            (28.5655, -81.6465)
        ],
        "South-east pockets (smaller blue clusters toward SR-429 side, but not the highway itself)": [
            (28.5625, -81.6200),
            (28.5625, -81.6025),
            (28.5505, -81.6025),
            (28.5505, -81.6200),
            (28.5625, -81.6200)
        ]
    ]
        
    
    func getPolygons() -> [MKPolygon] {
        var allPolygons: [MKPolygon] = []
        for (_, rawCoordList) in wg_calculated_coords_dict{
            var allCoords: [CLLocationCoordinate2D] = []
            for rawCoord in rawCoordList {
                allCoords.append(CLLocationCoordinate2D(latitude: rawCoord.0, longitude: rawCoord.1))
            }
            allPolygons.append(MKPolygon(coordinates: allCoords, count: allCoords.count))
        }
        return allPolygons
    }
    
    func getMultiPolygon() -> MKMultiPolygon {
        return MKMultiPolygon(self.getPolygons())
    }
    
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
    
    func is_valid_route(route: MKRoute) -> Bool {
        let points = route.polyline.points()
        let pointsCount = route.polyline.pointCount
        
        for i in 0..<pointsCount {
            let mapPoint = points[i]
            let coordinate = mapPoint.coordinate
            
            if !self.is_valid_point(location: coordinate) {
                print("invalid route; point outside polygon")
                return false
            }
        }
        return true
    }
}

