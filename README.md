# Golf Cart Path

A Go web app for exploring golf-cart-accessible routes around downtown Winter Garden, Florida.

The browser displays the supported district and translated golf-cart roadways. Approved OpenStreetMap way IDs provide exact road geometry, including explicitly approved private roads. The Go server snaps locations to that allowlisted graph only when they are within 50 meters, then uses Dijkstra's algorithm to find the shortest connected path.

## Run locally

Go 1.26 or newer is recommended.

```sh
go run ./cmd/server
```

Open <http://localhost:8080>. The server loads allowlisted road geometry from OpenStreetMap once at startup; route calculation then runs locally.

Run the tests with:

```sh
go test ./...
```

## Project layout

- `cmd/server`: application entry point
- `internal/app`: HTTP API, district geometry, and route validation
- `internal/app/web`: embedded HTML, CSS, and JavaScript frontend
- `GolfCartPath`: original Swift prototype, retained during the migration

## Important limitation

The current road graph is a small pilot transcription around the original Tildenville test route. Its segments are deliberately marked unverified. Every segment must be checked against the city's current map and street-level rules before the app is used for navigation. See the [official Winter Garden golf cart information](https://www.cwgdn.com/480/Golf-Cart-Information).

The pilot allowlist includes Civitas Way and Zachary Wade Street, along with their exact OpenStreetMap centerline geometry.
