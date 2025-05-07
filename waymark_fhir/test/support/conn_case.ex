defmodule WaymarkFhirWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use WaymarkFhirWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint WaymarkFhirWeb.Endpoint

      use WaymarkFhirWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import WaymarkFhirWeb.ConnCase
      import WaymarkFhir.QueryFixtures
      import Phoenix.LiveViewTest
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(WaymarkFhir.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(WaymarkFhir.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in waymarkers.

      setup :register_and_log_in_waymarker

  It stores an updated connection and a registered waymarker in the
  test context.
  """
  def register_and_log_in_waymarker(%{conn: conn}) do
    waymarker = WaymarkFhir.QueryFixtures.waymarker_fixture()
    %{conn: log_in_waymarker(conn, waymarker), waymarker: waymarker}
  end

  @doc """
  Logs the waymarker `in`.

  It returns an updated connection.
  """
  def log_in_waymarker(conn, waymarker) do
    token = WaymarkFhirWeb.WaymarkerAuthToken.sign(waymarker)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:waymarker_token, token)
  end
end
