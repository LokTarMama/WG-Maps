//
//  ContentView.swift
//  GolfCartPath
//
//  Created by Andrea Adams on 1/10/26.
//

import SwiftUI
import CoreData
import CoreLocation
import MapKit

public let startLat = 28.56326
public let startLong = -81.60827

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var mapViewModel = MapViewCalculator()
    @State private var position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: startLat, longitude: startLong),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    let winterGarden = WinterGarden()

    var body: some View {
        VStack {
            Map(position: $position, content: {
                Marker("My Location", coordinate: CLLocationCoordinate2D(
                        latitude: startLat,
                        longitude: startLong)
                )
                
                
//                // Iterate over individual MKPolygons within the MKMultiPolygon
//                ForEach(winterGarden.getMultiPolygon().polygons, id: \.hashValue) { polygon in
//                    MapPolygon(polygon)
//                        .stroke(.blue, lineWidth: 2) // Style your polygon
//                }

                MapPolygon(winterGarden.getPolygon())
                    .stroke(.blue, lineWidth: 2)
                    .foregroundStyle(Color.blue.opacity(0.3))
            })
            .mapControls {
                // Add built-in controls (optional)
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onAppear{
                mapViewModel.calculate_path_to_school()
            }
        }
    }
}

// 6. Helper struct to make CLLocationCoordinate2D identifiable for annotationItems
struct CLLocationCoordinate2DWrapper: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

