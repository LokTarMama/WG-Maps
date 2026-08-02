package app

import (
	"embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

//go:embed web/*
var webFiles embed.FS

type Server struct {
	routerURL string
	client    *http.Client
}

func NewServer(routerURL string) *Server {
	return &Server{
		routerURL: strings.TrimRight(routerURL, "/"),
		client:    &http.Client{Timeout: 12 * time.Second},
	}
}

func (s *Server) Routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/district", s.district)
	mux.HandleFunc("GET /api/route", s.route)
	assets, err := fs.Sub(webFiles, "web")
	if err != nil {
		panic(err)
	}
	mux.Handle("/", http.FileServer(http.FS(assets)))
	return mux
}

func (s *Server) district(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, winterGarden)
}

type osrmResponse struct {
	Code   string `json:"code"`
	Routes []struct {
		Distance float64 `json:"distance"`
		Duration float64 `json:"duration"`
		Geometry struct {
			Coordinates [][]float64 `json:"coordinates"`
			Type        string      `json:"type"`
		} `json:"geometry"`
	} `json:"routes"`
}

func (s *Server) route(w http.ResponseWriter, r *http.Request) {
	start, err := queryPoint(r.URL.Query(), "start")
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	end, err := queryPoint(r.URL.Query(), "end")
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	if !winterGarden.Contains(start) || !winterGarden.Contains(end) {
		writeError(w, http.StatusBadRequest, "both points must be inside the supported district")
		return
	}

	endpoint := fmt.Sprintf("%s/route/v1/driving/%f,%f;%f,%f?alternatives=true&overview=full&geometries=geojson",
		s.routerURL, start.Longitude, start.Latitude, end.Longitude, end.Latitude)
	response, err := s.client.Get(endpoint)
	if err != nil {
		writeError(w, http.StatusBadGateway, "routing service is unavailable")
		return
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		writeError(w, http.StatusBadGateway, "routing service returned an error")
		return
	}

	var candidates osrmResponse
	if err := json.NewDecoder(response.Body).Decode(&candidates); err != nil {
		writeError(w, http.StatusBadGateway, "routing service returned invalid data")
		return
	}
	for _, candidate := range candidates.Routes {
		valid := true
		for _, coordinate := range candidate.Geometry.Coordinates {
			if len(coordinate) < 2 || !winterGarden.Contains(Point{Latitude: coordinate[1], Longitude: coordinate[0]}) {
				valid = false
				break
			}
		}
		if valid {
			writeJSON(w, http.StatusOK, candidate)
			return
		}
	}
	writeError(w, http.StatusNotFound, "no route stays inside the supported district")
}

func queryPoint(values url.Values, name string) (Point, error) {
	raw := strings.Split(values.Get(name), ",")
	if len(raw) != 2 {
		return Point{}, fmt.Errorf("%s must use latitude,longitude", name)
	}
	latitude, latErr := strconv.ParseFloat(raw[0], 64)
	longitude, longErr := strconv.ParseFloat(raw[1], 64)
	if latErr != nil || longErr != nil || latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180 {
		return Point{}, fmt.Errorf("%s contains invalid coordinates", name)
	}
	return Point{Latitude: latitude, Longitude: longitude}, nil
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}
