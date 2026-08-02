package app

import "testing"

func testNetwork() *RoadNetwork {
	return NewRoadNetwork([]RoadSegment{
		{ID: "short", Coordinates: []Point{{Latitude: 0, Longitude: 0}, {Latitude: 0, Longitude: .002}}},
		{ID: "long", Coordinates: []Point{{Latitude: 0, Longitude: 0}, {Latitude: .002, Longitude: .001}, {Latitude: 0, Longitude: .002}}},
	})
}

func TestRoadNetworkChoosesShortestPath(t *testing.T) {
	route, err := testNetwork().Route(Point{Latitude: 0, Longitude: 0}, Point{Latitude: 0, Longitude: .002})
	if err != nil {
		t.Fatal(err)
	}
	for _, coordinate := range route.Geometry.Coordinates {
		if coordinate[1] != 0 {
			t.Fatalf("route used the longer branch: %+v", route.Geometry.Coordinates)
		}
	}
}

func TestRoadNetworkRejectsDistantPoint(t *testing.T) {
	_, err := testNetwork().Route(Point{Latitude: 0, Longitude: 0}, Point{Latitude: .01, Longitude: .01})
	if err == nil {
		t.Fatal("expected a point away from the network to be rejected")
	}
}

func TestLongOSMSegmentGetsRoutingNodes(t *testing.T) {
	network := NewRoadNetwork([]RoadSegment{{Coordinates: []Point{
		{Latitude: 28.5637305, Longitude: -81.6085667},
		{Latitude: 28.5624038, Longitude: -81.6084895},
	}}})
	_, err := network.Route(
		Point{Latitude: 28.56326, Longitude: -81.60850},
		Point{Latitude: 28.56250, Longitude: -81.60849},
	)
	if err != nil {
		t.Fatalf("points beside a long OSM segment should snap to interpolated graph nodes: %v", err)
	}
}
