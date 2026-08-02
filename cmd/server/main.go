package main

import (
	"log"
	"net/http"
	"os"

	"golfcartpath/internal/app"
)

func main() {
	addr := env("ADDR", ":8080")
	routerURL := env("ROUTER_URL", "https://router.project-osrm.org")

	server := app.NewServer(routerURL)
	log.Printf("Golf Cart Path is available at http://localhost%s", addr)
	log.Fatal(http.ListenAndServe(addr, server.Routes()))
}

func env(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}
