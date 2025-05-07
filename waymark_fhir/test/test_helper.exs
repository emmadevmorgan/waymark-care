# Start ExUnit
ExUnit.start()

# Start the Repo
{:ok, _} = Application.ensure_all_started(:waymark_fhir)

# Configure the database for testing
Ecto.Adapters.SQL.Sandbox.mode(WaymarkFhir.Repo, :manual)

# Stop the RabbitMQ consumer for tests if it's running
case Process.whereis(WaymarkFhir.Messaging.Consumer) do
  nil -> :ok
  pid -> Supervisor.terminate_child(WaymarkFhir.Supervisor, pid)
end
