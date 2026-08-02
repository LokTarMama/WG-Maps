//
//  GolfCartPathTests.swift
//  GolfCartPathTests
//
//  Created by Andrea Adams on 1/10/26.
//

import Testing
internal import MapKit
@testable import GolfCartPath
import SwiftUI

struct MapViewCalculatorInitalizersTests {
    //--------------------
    // test constants
    //--------------------

    let testStartLat = 28.56326
    let testStartLong = -81.60827
    let testEndLat = 28.56053
    let testEndLong = -81.60863


    //--------------------
    // Initalizers
    //--------------------

    @Test func testDefaultMapViewCalculator_HappyPath() throws {
        let testClient = MapViewCalculator()
        _validateHelper(testClient)
    }

    @Test func testMapViewCalculator_HappyPath() throws {
        let testClient = MapViewCalculator(
            startLatitude: testStartLat,
            startLongitude: testStartLong,
            endLatitude: testEndLat,
            endLongitude: testEndLong)
        _validateHelper(testClient)
    }

    //--------------------
    // Helpers
    //--------------------

    func _validateHelper(_ testClient: MapViewCalculator) {
        #expect(testClient.startCoord.latitude == testStartLat, "failed to set default start lat")
        #expect(testClient.startCoord.longitude == testStartLong, "failed to set default start long")
        #expect(testClient.endCoord.latitude == testEndLat, "failed to set default end lat")
        #expect(testClient.endCoord.longitude == testEndLong, "failed to set default end long")
    }
}

