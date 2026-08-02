package app

import "testing"

func TestDistrictContains(t *testing.T) {
	tests := []struct {
		name  string
		point Point
		want  bool
	}{
		{name: "inside", point: Point{Latitude: 28.56326, Longitude: -81.60827}, want: true},
		{name: "outside", point: Point{Latitude: 28.56416, Longitude: -81.59052}, want: false},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := winterGarden.Contains(test.point); got != test.want {
				t.Fatalf("Contains(%+v) = %v, want %v", test.point, got, test.want)
			}
		})
	}
}
