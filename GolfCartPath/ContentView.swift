//
//  ContentView.swift
//  GolfCartPath
//
//  Created by Andrea Adams on 1/10/26.
//

import SwiftUI
import CoreData
import MapKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.7878, longitude: -74.9323),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )

    var body: some View {
        VStack {
                Map(position: $position) {
                    // Add map content here using the new APIs (Marker, Annotation, UserAnnotation)

                    // Example: Add a Marker
                    Marker("My Location", coordinate: CLLocationCoordinate2D(latitude: 42.7878, longitude: -74.9323))

                    // Example: Show the user's current location control
                    UserAnnotation()
                }
                .mapControls {
                    // Add built-in controls (optional)
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
            }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

// 6. Helper struct to make CLLocationCoordinate2D identifiable for annotationItems
struct CLLocationCoordinate2DWrapper: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
