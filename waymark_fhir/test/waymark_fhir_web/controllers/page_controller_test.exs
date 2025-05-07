defmodule WaymarkFhirWeb.PageControllerTest do
  use WaymarkFhirWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Waymark FHIR Integration"
  end
end
