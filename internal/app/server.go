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
	"sync"
	"time"
)

//go:embed web/*
var webFiles embed.FS

type Server struct {
	osmURL      string
	client      *http.Client
	networkOnce sync.Once
	network     *RoadNetwork
	networkErr  error
}

func NewServer(osmURL string) *Server {
	return &Server{
		osmURL: strings.TrimRight(osmURL, "/"),
		client: &http.Client{Timeout: 15 * time.Second},
	}
}

func (s *Server) Routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/district", s.district)
	mux.HandleFunc("GET /api/network", s.networkData)
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

func (s *Server) networkData(w http.ResponseWriter, _ *http.Request) {
	network, err := s.roadNetwork()
	if err != nil {
		writeError(w, http.StatusBadGateway, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, network)
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
	network, err := s.roadNetwork()
	if err != nil {
		writeError(w, http.StatusBadGateway, err.Error())
		return
	}
	route, err := network.Route(start, end)
	if err != nil {
		status := http.StatusNotFound
		if strings.Contains(err.Error(), "meters from the translated network") {
			status = http.StatusBadRequest
		}
		writeError(w, status, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, route)
}

func (s *Server) roadNetwork() (*RoadNetwork, error) {
	s.networkOnce.Do(func() {
		s.network, s.networkErr = loadApprovedNetwork(s.client, s.osmURL)
	})
	return s.network, s.networkErr
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
