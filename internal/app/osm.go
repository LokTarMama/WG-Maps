package app

import (
	"encoding/xml"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
)

// These ways are explicitly opted in from the official golf-cart map. OSM is
// used only for their centerline geometry; its access tags do not decide
// whether a way is approved.
var approvedWayIDs = map[int64]bool{
	11201064:   true, // Desiree Aurora Street (private)
	11185270:   true, // Lakeview Reserve Boulevard
	44766971:   true, // Lakeview Reserve Boulevard (continuation)
	44766974:   true, // Lakeview Reserve Boulevard (continuation)
	967394999:  true, // Lakeview Reserve Boulevard (continuation)
	967395000:  true, // Lakeview Reserve Boulevard (continuation)
	139007923:  true, // Bluffton Way
	139007927:  true, // Easley Avenue
	139007928:  true, // Eastover Loop
	139007939:  true, // Union Club Drive
	817066284:  true, // Civitas Way (west of Lake Brim Drive)
	1204894259: true, // Civitas Way (east continuation to Tildenville School Road)
	76957838:   true, // Tildenville School Road
	157421591:  true, // Tildenville School Road (east continuation)
	11189376:   true, // Zachary Wade Street
}

const pilotBBox = "-81.6125,28.5600,-81.6070,28.5666"

type osmDocument struct {
	Nodes []osmNode `xml:"node"`
	Ways  []osmWay  `xml:"way"`
}

type osmNode struct {
	ID        int64   `xml:"id,attr"`
	Latitude  float64 `xml:"lat,attr"`
	Longitude float64 `xml:"lon,attr"`
}

type osmWay struct {
	ID   int64    `xml:"id,attr"`
	Refs []osmRef `xml:"nd"`
	Tags []osmTag `xml:"tag"`
}

type osmRef struct {
	Ref int64 `xml:"ref,attr"`
}
type osmTag struct {
	Key   string `xml:"k,attr"`
	Value string `xml:"v,attr"`
}

func loadApprovedNetwork(client *http.Client, baseURL string) (*RoadNetwork, error) {
	endpoint := strings.TrimRight(baseURL, "/") + "/api/0.6/map?bbox=" + pilotBBox
	response, err := client.Get(endpoint)
	if err != nil {
		return nil, fmt.Errorf("load OpenStreetMap geometry: %w", err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("load OpenStreetMap geometry: status %d", response.StatusCode)
	}
	return parseApprovedNetwork(response.Body)
}

func parseApprovedNetwork(reader io.Reader) (*RoadNetwork, error) {
	var document osmDocument
	if err := xml.NewDecoder(reader).Decode(&document); err != nil {
		return nil, fmt.Errorf("decode OpenStreetMap geometry: %w", err)
	}
	nodes := make(map[int64]Point, len(document.Nodes))
	for _, node := range document.Nodes {
		nodes[node.ID] = Point{Latitude: node.Latitude, Longitude: node.Longitude}
	}
	segments := make([]RoadSegment, 0, len(approvedWayIDs))
	for _, way := range document.Ways {
		if !approvedWayIDs[way.ID] {
			continue
		}
		segment := RoadSegment{ID: strconv.FormatInt(way.ID, 10), Verified: true}
		for _, tag := range way.Tags {
			if tag.Key == "name" {
				segment.Name = tag.Value
			}
		}
		for _, ref := range way.Refs {
			point, ok := nodes[ref.Ref]
			if !ok {
				return nil, fmt.Errorf("way %d references missing node %d", way.ID, ref.Ref)
			}
			segment.Coordinates = append(segment.Coordinates, point)
		}
		if len(segment.Coordinates) >= 2 {
			segments = append(segments, segment)
		}
	}
	if len(segments) == 0 {
		return nil, fmt.Errorf("OpenStreetMap response contained no approved ways")
	}
	return NewRoadNetwork(segments), nil
}
