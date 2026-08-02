package app

import (
	"os"
	"strings"
	"testing"
)

func TestParseApprovedNetwork(t *testing.T) {
	xml := `<osm>
<node id="1" lat="28.563" lon="-81.608"/>
<node id="2" lat="28.562" lon="-81.608"/>
<way id="11201064"><nd ref="1"/><nd ref="2"/><tag k="highway" v="residential"/><tag k="access" v="private"/><tag k="name" v="Desiree Aurora Street"/></way>
<way id="999"><nd ref="1"/><nd ref="2"/><tag k="highway" v="residential"/><tag k="name" v="Not Approved"/></way>
</osm>`
	network, err := parseApprovedNetwork(strings.NewReader(xml))
	if err != nil {
		t.Fatal(err)
	}
	if len(network.Segments) != 1 || network.Segments[0].ID != "11201064" {
		t.Fatalf("segments = %+v, want only explicitly approved way", network.Segments)
	}
}

func TestDownloadedPilotExtractRoutesFromDesireeToTildenville(t *testing.T) {
	path := os.Getenv("OSM_FIXTURE")
	if path == "" {
		t.Skip("set OSM_FIXTURE to test a downloaded OSM extract")
	}
	file, err := os.Open(path)
	if err != nil {
		t.Fatal(err)
	}
	defer file.Close()
	network, err := parseApprovedNetwork(file)
	if err != nil {
		t.Fatal(err)
	}
	startNode, startDistance := network.nearestNode(Point{Latitude: 28.56326, Longitude: -81.60827})
	endNode, endDistance := network.nearestNode(Point{Latitude: 28.56053, Longitude: -81.60863})
	if startDistance > maxSnapDistanceMeters || network.nodes[startNode].Longitude < -81.609 {
		t.Fatalf("start snapped %.1fm to %+v instead of nearby Desiree Aurora Street", startDistance, network.nodes[startNode])
	}
	if endDistance > maxSnapDistanceMeters {
		t.Fatalf("destination snapped %.1fm to %+v", endDistance, network.nodes[endNode])
	}
	route, err := network.Route(
		Point{Latitude: 28.56326, Longitude: -81.60827},
		Point{Latitude: 28.56053, Longitude: -81.60863},
	)
	if err != nil {
		t.Fatalf("Civitas Way should connect Desiree Aurora Street to Tildenville School Road: %v", err)
	}
	if len(route.Geometry.Coordinates) < 2 {
		t.Fatalf("route has %d coordinates, want at least 2", len(route.Geometry.Coordinates))
	}
}
