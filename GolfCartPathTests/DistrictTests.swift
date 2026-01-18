//
//  DistrictTests.swift
//  GolfCartPath
//
//  Created by Andrea Adams on 1/18/26.
//

import Testing
import CoreLocation
@testable import GolfCartPath

struct DistrictTests {
    var testClient: WinterGarden!
    
    init() async {
        self.testClient = await WinterGarden()
    }
    
    
    @Test("Test District IsValidPoint")
    func testDistrictIsValidPoint_HappyPath() {
        // 28.56416° N, 81.59052° W
        let crookecCan = CLLocationCoordinate2D(latitude: 28.56416, longitude: -81.59052)
        #expect(self.testClient.is_valid_point(location: crookecCan))
    }
}

