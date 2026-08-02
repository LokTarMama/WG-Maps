const map = L.map("map").setView([28.562, -81.6105], 15);
L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  maxZoom: 19,
  attribution: "&copy; OpenStreetMap contributors"
}).addTo(map);

let district;
let roadNetwork;
let start;
let end;
let routeLine;
const markers = [];
const status = document.querySelector("#status");

fetch("/api/district")
  .then(response => response.json())
  .then(data => {
    district = L.polygon(data.boundary.map(point => [point.latitude, point.longitude]), {
      color: "#26725d", fillColor: "#58a58b", fillOpacity: 0.24, weight: 3
    }).addTo(map);
    map.fitBounds(district.getBounds(), { padding: [24, 24] });
  })
  .catch(() => setStatus("Could not load the district."));

fetch("/api/network")
  .then(response => response.json())
  .then(data => {
    roadNetwork = L.featureGroup(data.segments.map(segment =>
      L.polyline(segment.coordinates.map(point => [point.latitude, point.longitude]), {
        color: "#2672d3", weight: 6, opacity: segment.verified ? 1 : 0.75
      }).bindTooltip(`${segment.name}${segment.verified ? "" : " (pilot transcription)"}`)
    )).addTo(map);
  })
  .catch(() => setStatus("Could not load the translated road network."));

map.on("click", event => choosePoint(event.latlng));
document.querySelector("#resetButton").addEventListener("click", reset);
document.querySelector("#locationButton").addEventListener("click", () => {
  setStatus("Finding your location…");
  navigator.geolocation.getCurrentPosition(
    position => choosePoint(L.latLng(position.coords.latitude, position.coords.longitude)),
    () => setStatus("Location access was unavailable.")
  );
});

function choosePoint(point) {
  if (!roadNetwork) {
    setStatus("The translated road network is still loading.");
    return;
  }
  if (start && end) reset();
  const marker = L.marker(point).addTo(map);
  markers.push(marker);
  if (!start) {
    start = point;
    document.querySelector("#startText").textContent = "✓ Starting point selected";
    setStatus("Now choose a destination.");
    return;
  }
  end = point;
  document.querySelector("#endText").textContent = "✓ Destination selected";
  findRoute();
}

async function findRoute() {
  setStatus("Looking for a route…");
  const query = new URLSearchParams({ start: `${start.lat},${start.lng}`, end: `${end.lat},${end.lng}` });
  try {
    const response = await fetch(`/api/route?${query}`);
    const data = await response.json();
    if (!response.ok) throw new Error(data.error || "No route found");
    routeLine = L.geoJSON(data.geometry, { style: { color: "#d17d18", weight: 6 } }).addTo(map);
    map.fitBounds(routeLine.getBounds(), { padding: [40, 40] });
    setStatus(`${(data.distance / 1609.344).toFixed(2)} mi · about ${Math.max(1, Math.round(data.duration / 60))} min`);
  } catch (error) {
    setStatus(error.message);
  }
}

function reset() {
  markers.splice(0).forEach(marker => marker.remove());
  if (routeLine) routeLine.remove();
  start = end = routeLine = undefined;
  document.querySelector("#startText").textContent = "1. Choose a starting point";
  document.querySelector("#endText").textContent = "2. Choose a destination";
  setStatus("Click the map to begin.");
}

function setStatus(message) { status.textContent = message; }
