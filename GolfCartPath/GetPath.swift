import SwiftUI
import MapKit
import CoreLocation
import Contacts
internal import Combine

public let endLat = 28.56053
public let endLong = -81.60863

@Observable
class MapViewCalculator: ObservableObject {
    var my_route: MKRoute?
    var startCoord = CLLocationCoordinate2D(latitude: startLat, longitude: startLong)
    var endCoord = CLLocationCoordinate2D(latitude: endLat, longitude: endLong)
    
    init(){}
    
    init(startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double){
        self.startCoord = CLLocationCoordinate2D(
            latitude: startLatitude,
            longitude: startLongitude)
        self.endCoord = CLLocationCoordinate2D(
            latitude: endLatitude,
            longitude: endLongitude)
    }
    
    func calculate_path_to_school() {
        let startLocation = CLLocation(
            latitude: startCoord.latitude,
            longitude: startCoord.longitude)
        let endLocation = CLLocation(
            latitude: self.endCoord.latitude,
            longitude: self.endCoord.longitude)

        let start = MKMapItem(
            location: startLocation,
            address: nil)
        start.name = "Starting Point"
        
        let end = MKMapItem(
            location: endLocation,
            address: nil)
        end.name = "Final Destination"

        let request = MKDirections.Request()
        request.source = start
        request.destination = end
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response, error == nil else {
                print("Error calculating directions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let route = response.routes.first {
                print("Successfully calculated route. Distance: \(route.distance) meters")
                self.my_route = route
                return
            }
            print("no route found")
            return
        }
    }
}

