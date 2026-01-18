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

    var body: some View {
        VStack {
            Map(position: $position) {
                Marker("My Location", coordinate: CLLocationCoordinate2D(
                        latitude: startLat,
                        longitude: startLong)
                )
                
                if let route = mapViewModel.my_route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
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
