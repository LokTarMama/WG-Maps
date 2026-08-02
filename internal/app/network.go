package app

import (
	"container/heap"
	"errors"
	"fmt"
	"math"
)

// Keep snapping close enough that a selected address cannot jump across a block
// or onto a different neighborhood street.
const maxSnapDistanceMeters = 50.0

type RoadSegment struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Coordinates []Point `json:"coordinates"`
	Verified    bool    `json:"verified"`
	Notes       string  `json:"notes,omitempty"`
}

type RoadNetwork struct {
	Segments []RoadSegment `json:"segments"`
	nodes    []Point
	edges    map[int][]edge
}

type edge struct {
	to       int
	distance float64
}

type Route struct {
	Distance float64  `json:"distance"`
	Duration float64  `json:"duration"`
	Geometry geometry `json:"geometry"`
}

type geometry struct {
	Coordinates [][]float64 `json:"coordinates"`
	Type        string      `json:"type"`
}

func NewRoadNetwork(segments []RoadSegment) *RoadNetwork {
	network := &RoadNetwork{Segments: segments, edges: make(map[int][]edge)}
	for _, segment := range segments {
		previous := -1
		for index, point := range segment.Coordinates {
			points := []Point{point}
			if index > 0 {
				points = interpolate(segment.Coordinates[index-1], point, 15)
			}
			for _, graphPoint := range points {
				current := network.node(graphPoint)
				if previous >= 0 && previous != current {
					distance := haversine(network.nodes[previous], network.nodes[current])
					network.edges[previous] = append(network.edges[previous], edge{to: current, distance: distance})
					network.edges[current] = append(network.edges[current], edge{to: previous, distance: distance})
				}
				previous = current
			}
		}
	}
	return network
}

func interpolate(a, b Point, maximumSpacing float64) []Point {
	steps := int(math.Ceil(haversine(a, b) / maximumSpacing))
	points := make([]Point, 0, steps)
	for step := 1; step <= steps; step++ {
		fraction := float64(step) / float64(steps)
		points = append(points, Point{
			Latitude:  a.Latitude + (b.Latitude-a.Latitude)*fraction,
			Longitude: a.Longitude + (b.Longitude-a.Longitude)*fraction,
		})
	}
	return points
}

func (n *RoadNetwork) node(point Point) int {
	for index, existing := range n.nodes {
		if haversine(existing, point) < 1 {
			return index
		}
	}
	n.nodes = append(n.nodes, point)
	return len(n.nodes) - 1
}

func (n *RoadNetwork) Route(start, end Point) (Route, error) {
	startNode, startDistance := n.nearestNode(start)
	endNode, endDistance := n.nearestNode(end)
	if startDistance > maxSnapDistanceMeters {
		return Route{}, fmt.Errorf("starting point is %.0f meters from the translated network; maximum is %.0f", startDistance, maxSnapDistanceMeters)
	}
	if endDistance > maxSnapDistanceMeters {
		return Route{}, fmt.Errorf("destination is %.0f meters from the translated network; maximum is %.0f", endDistance, maxSnapDistanceMeters)
	}

	distances := make([]float64, len(n.nodes))
	previous := make([]int, len(n.nodes))
	for index := range distances {
		distances[index] = math.Inf(1)
		previous[index] = -1
	}
	distances[startNode] = 0
	queue := &priorityQueue{{node: startNode, distance: 0}}
	heap.Init(queue)

	for queue.Len() > 0 {
		current := heap.Pop(queue).(queueItem)
		if current.distance != distances[current.node] {
			continue
		}
		if current.node == endNode {
			break
		}
		for _, next := range n.edges[current.node] {
			candidate := current.distance + next.distance
			if candidate < distances[next.to] {
				distances[next.to] = candidate
				previous[next.to] = current.node
				heap.Push(queue, queueItem{node: next.to, distance: candidate})
			}
		}
	}
	if math.IsInf(distances[endNode], 1) {
		return Route{}, errors.New("no connected golf-cart route was found")
	}

	path := []int{}
	for node := endNode; node >= 0; node = previous[node] {
		path = append(path, node)
		if node == startNode {
			break
		}
	}
	coordinates := make([][]float64, 0, len(path))
	for index := len(path) - 1; index >= 0; index-- {
		point := n.nodes[path[index]]
		coordinates = append(coordinates, []float64{point.Longitude, point.Latitude})
	}
	distance := distances[endNode]
	return Route{
		Distance: distance,
		Duration: distance / 5.36448, // 12 mph estimate; not a legal speed recommendation.
		Geometry: geometry{Type: "LineString", Coordinates: coordinates},
	}, nil
}

func (n *RoadNetwork) nearestNode(point Point) (int, float64) {
	nearest, distance := -1, math.Inf(1)
	for index, candidate := range n.nodes {
		if candidateDistance := haversine(point, candidate); candidateDistance < distance {
			nearest, distance = index, candidateDistance
		}
	}
	return nearest, distance
}

func haversine(a, b Point) float64 {
	const earthRadiusMeters = 6371000
	lat1, lat2 := a.Latitude*math.Pi/180, b.Latitude*math.Pi/180
	deltaLat := (b.Latitude - a.Latitude) * math.Pi / 180
	deltaLong := (b.Longitude - a.Longitude) * math.Pi / 180
	h := math.Sin(deltaLat/2)*math.Sin(deltaLat/2) + math.Cos(lat1)*math.Cos(lat2)*math.Sin(deltaLong/2)*math.Sin(deltaLong/2)
	return earthRadiusMeters * 2 * math.Atan2(math.Sqrt(h), math.Sqrt(1-h))
}

type queueItem struct {
	node     int
	distance float64
}

type priorityQueue []queueItem

func (q priorityQueue) Len() int           { return len(q) }
func (q priorityQueue) Less(i, j int) bool { return q[i].distance < q[j].distance }
func (q priorityQueue) Swap(i, j int)      { q[i], q[j] = q[j], q[i] }
func (q *priorityQueue) Push(value any)    { *q = append(*q, value.(queueItem)) }
func (q *priorityQueue) Pop() any {
	old := *q
	item := old[len(old)-1]
	*q = old[:len(old)-1]
	return item
}
