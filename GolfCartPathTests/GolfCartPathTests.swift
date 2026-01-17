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

struct MapViewCalculatorTests {
    let testClient: MapViewCalculator
    init() async throws {
        self.testClient = await MapViewCalculator()
    }
    

    //--------------------
    // Calculate Path to School
    //--------------------

    @Test func testCalculatePathToSchool_HappyPath() async throws {
        await self.testClient.calculate_path_to_school()
        try await Task.sleep(for: .seconds(1))

        let resultRoute: MKRoute? = await MainActor.run { self.testClient.my_route }
        let unwrappedRoute = try #require(resultRoute)
        #expect(unwrappedRoute.distance == 2858.0)
    }
}

