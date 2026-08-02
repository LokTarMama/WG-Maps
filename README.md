# Golf Cart Path

A Go web app for exploring golf-cart-accessible routes around downtown Winter Garden, Florida.

The browser displays the supported district, accepts a starting point and destination, and asks the Go server for road-route candidates. The server returns the first candidate whose complete geometry stays inside the district boundary.

## Run locally

Go 1.26 or newer is recommended.

```sh
go run ./cmd/server
```

Open <http://localhost:8080>. The map and default routing service require an internet connection.

Run the tests with:

```sh
go test ./...
```

Configuration:

- `ADDR` changes the listening address (default `:8080`).
- `ROUTER_URL` changes the OSRM-compatible routing service.

## Project layout

- `cmd/server`: application entry point
- `internal/app`: HTTP API, district geometry, and route validation
- `internal/app/web`: embedded HTML, CSS, and JavaScript frontend
- `GolfCartPath`: original Swift prototype, retained during the migration

## Important limitation

Remaining inside a district boundary does not prove that every road is legal or safe for golf carts. This prototype must be checked against the city's current street-level rules before being used for navigation. See the [official Winter Garden golf cart information](https://www.cwgdn.com/480/Golf-Cart-Information).
