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
    
    @State private var route: MKRoute?
    
    @State private var directions_to_school = requestDirectionsWithMapItems
    
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
                    
//                    requestDirectionsWithMapItems()
                    if let route {
                        MapPolyline(route.polyline)
                            .stroke(.blue, lineWidth: 5)
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
                    requestDirectionsWithMapItems()
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
