defmodule WaymarkFhir.Repo do
  use Ecto.Repo,
    otp_app: :waymark_fhir,
    adapter: Ecto.Adapters.Postgres
end
