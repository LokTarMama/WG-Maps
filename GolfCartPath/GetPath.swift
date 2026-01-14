import MapKit
import CoreLocation
import Contacts // Required for address dictionary constants if needed

func requestDirectionsWithMapItems() {
    print("HelllOOOOooooo!!!! from requestDirectionsWithMapItems")
    // 1. Define coordinates for source and destination
    let sourceCoordinate = CLLocationCoordinate2D(latitude: 28.56326, longitude: -81.60827) // Example: New York City
    let destinationCoordinate = CLLocationCoordinate2D(latitude: 28.56053, longitude: -81.60863) // Example: Los Angeles

    // 2. Create CLLocation objects for the locations
    let sourceLocation = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
    let destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)

    // 3. (Optional) Create MKAddress objects for more detailed information.
    // If you only have coordinates, you can pass 'nil' for the address,
    // or use a geocoder to fetch the full address details.
    let sourceAddress = MKAddress(fullAddress: "85 Desiree Aurora St, Winter Garden, FL, USA", shortAddress: "Home")
    let destinationAddress = MKAddress(fullAddress: "1065 Tildenville Dr, Winter Garden, FL, USA", shortAddress: "DropOff")

    // 4. Create MKMapItem objects using the modern initializer
    let sourceMapItem = MKMapItem(location: sourceLocation, address: sourceAddress)
    sourceMapItem.name = "Starting Point" // Set a display name
    
    let destinationMapItem = MKMapItem(location: destinationLocation, address: destinationAddress)
    destinationMapItem.name = "Final Destination"

    // 5. Create the MKDirections.Request
    let request = MKDirections.Request()
    request.source = sourceMapItem
    request.destination = destinationMapItem
    request.transportType = .automobile
    request.requestsAlternateRoutes = true

    // 6. Calculate the directions
    let directions = MKDirections(request: request)
    directions.calculate { response, error in
        guard let response = response, error == nil else {
            // Handle the error appropriately
            print("Error calculating directions: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        // Process the response (e.g., add routes to an MKMapView)
        if let route = response.routes.first {
            print("Successfully calculated route. Distance: \(route.distance) meters")
            // Example of accessing address information from the resulting map items
            if let fullAddress = response.source.addressRepresentations?.fullAddress(includingRegion: false, singleLine: true) {
                print("Source address: \(fullAddress)")
            }
            return
        }
        return
    }
}
