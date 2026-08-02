package app

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestDistrictEndpoint(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/api/district", nil)
	recorder := httptest.NewRecorder()
	NewServer("").Routes().ServeHTTP(recorder, request)

	if recorder.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusOK)
	}
	if !strings.Contains(recorder.Body.String(), winterGarden.Name) {
		t.Fatalf("response does not contain district name: %s", recorder.Body.String())
	}
}

func TestRouteRejectsPointOutsideDistrict(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/api/route?start=28.56326,-81.60827&end=28.56053,-81.59000", nil)
	recorder := httptest.NewRecorder()
	NewServer("").Routes().ServeHTTP(recorder, request)

	if recorder.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusBadRequest)
	}
}
