defmodule WaymarkFhir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WaymarkFhirWeb.Telemetry,
      WaymarkFhir.Repo,
      {DNSCluster, query: Application.get_env(:waymark_fhir, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WaymarkFhir.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WaymarkFhir.Finch, pools: %{default: [size: 10]}},
      # Start RabbitMQ consumer
      {Application.get_env(:waymark_fhir, :messaging_module, WaymarkFhir.Messaging.Consumer), []},
      # Start to serve requests, typically the last entry
      WaymarkFhirWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WaymarkFhir.Supervisor]

    # Start the supervisor
    {:ok, pid} = Supervisor.start_link(children, opts)

    {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WaymarkFhirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
