//
//  District.swift
//  GolfCartPath
//
//  Created by Andrea Adams on 1/17/26.
//

import MapKit

struct WinterGarden {
    private let wg_calculated_coords_list = [
        SubDistrict(
            metadata: SubDistrictMetadata(id: 0, name: "", description: ""),
            area: MKPolygon(
                coordinates: convert_to_coords(rawCoords: tildenville_elementary_raw_coords),
                count: tildenville_elementary_raw_coords.count))
    ]
    
    func getPolygons() -> [MKPolygon] {
        var allPolygons: [MKPolygon] = []
        for subDisctrict in wg_calculated_coords_list{
            allPolygons.append(subDisctrict.area)
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

struct SubDistrict {
    let metadata: SubDistrictMetadata
    let area: MKPolygon
    
    init(metadata: SubDistrictMetadata, area: MKPolygon) {
        self.metadata = metadata
        self.area = area
    }
}

struct SubDistrictMetadata : Codable {
    let id: Int
    let name: String
    let description: String
    
    init(id: Int, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}

let custome_route = MKRoute()

let tildenville_elementary_raw_coords = [
    (28.55739, -81.60893, "1344 Brick Road"),
    (28.55479, -81.61184, "801-811 Oakland Park Blvd"),
    (28.55477, -81.61581, "15541 E Oakland Ave"),
    (28.56874, -81.61710, "NorthWest corner in Lake Apopka"),
    (28.56885, -81.60658, "NorthEast corner in Lake Apopka"),
    (28.55744, -81.60455, "1124 Brik Road"),
    (28.55739, -81.60893, "1344 Brick Road")
]

func convert_to_coords(rawCoords: [(Double, Double, String)]) -> [CLLocationCoordinate2D] {
    var convertedCoords: [CLLocationCoordinate2D] = []
    
    for rawCoord in rawCoords {
        convertedCoords.append(CLLocationCoordinate2D(latitude: rawCoord.0, longitude: rawCoord.1))
    }
    
    return convertedCoords
}
