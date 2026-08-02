package app

type Point struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type District struct {
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Boundary    []Point `json:"boundary"`
}

var winterGarden = District{
	Name:        "Tildenville Elementary district",
	Description: "Golf-cart-accessible area transcribed from the official Winter Garden map.",
	Boundary: []Point{
		{Latitude: 28.55739, Longitude: -81.60893},
		{Latitude: 28.55479, Longitude: -81.61184},
		{Latitude: 28.55477, Longitude: -81.61581},
		{Latitude: 28.56874, Longitude: -81.61710},
		{Latitude: 28.56885, Longitude: -81.60658},
		{Latitude: 28.55744, Longitude: -81.60455},
	},
}

func (d District) Contains(point Point) bool {
	inside := false
	count := len(d.Boundary)
	for i, j := 0, count-1; i < count; j, i = i, i+1 {
		a, b := d.Boundary[i], d.Boundary[j]
		crosses := (a.Latitude > point.Latitude) != (b.Latitude > point.Latitude)
		if crosses && point.Longitude < (b.Longitude-a.Longitude)*(point.Latitude-a.Latitude)/(b.Latitude-a.Latitude)+a.Longitude {
			inside = !inside
		}
	}
	return inside
}
