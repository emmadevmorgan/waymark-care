import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :waymark_fhir, WaymarkFhir.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "waymark_fhir_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  ownership_timeout: 60_000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :waymark_fhir, WaymarkFhirWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+Hs+",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure RabbitMQ for testing
config :waymark_fhir, :rabbitmq,
  host: "localhost",
  port: 5672,
  username: "app_user",
  password: "rabbitmq",
  virtual_host: "homework",
  queue: "fhir-inbound-test"

# Use mock for RabbitMQ in tests
config :waymark_fhir, :messaging_module, WaymarkFhir.MessagingMock
