package main

import (
	"log"
	"net/http"
	"os"

	"golfcartpath/internal/app"
)

func main() {
	const addr = ":8080"
	osmURL := os.Getenv("OSM_URL")
	if osmURL == "" {
		osmURL = "https://api.openstreetmap.org"
	}
	server := app.NewServer(osmURL)
	log.Printf("Golf Cart Path is available at http://localhost%s", addr)
	log.Fatal(http.ListenAndServe(addr, server.Routes()))
}
