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

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @StateObject var mapViewModel = MapViewCalculator()
    
    @State private var directions_to_school: MKRoute?
    
    @State private var position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 28.56326, longitude: -81.60827),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )

    var body: some View {
        VStack {
                Map(position: $position) {
                    // Add map content here using the new APIs (Marker, Annotation, UserAnnotation)

                    // Example: Add a Marker
                    Marker("My Location", coordinate: CLLocationCoordinate2D(latitude: 28.56326, longitude: -81.60827))
                    
                    if let route = mapViewModel.my_route {
                        MapPolyline(route) // Draws the polyline from the MKRoute
                            .stroke(.blue, lineWidth: 5) // Customize the appearance
                    }

                    // Example: Show the user's current location control
                    UserAnnotation()
                }
                .mapControls {
                    // Add built-in controls (optional)
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .onAppear{
                    Task {
                        mapViewModel.requestDirectionsWithMapItems()
                        
                        // Optional: focus the map on the route
                        if let boundingBox = mapViewModel.my_route?.polyline.boundingMapRect {
                            position = .rect(boundingBox)
                        }
                    }
                }
            }
    }
}

// 6. Helper struct to make CLLocationCoordinate2D identifiable for annotationItems
struct CLLocationCoordinate2DWrapper: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
