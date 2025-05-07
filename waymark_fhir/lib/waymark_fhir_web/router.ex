defmodule WaymarkFhirWeb.Router do
  use WaymarkFhirWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WaymarkFhirWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WaymarkFhirWeb do
    pipe_through :browser

    # Waymarker routes
    live "/", PageLive, :index
    live "/waymarkers", WaymarkerLive.Index, :index
    live "/waymarkers/:id", WaymarkerLive.Show, :show
    live "/fhir", FhirLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", WaymarkFhirWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:waymark_fhir, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WaymarkFhirWeb.Telemetry
    end
  end
end
