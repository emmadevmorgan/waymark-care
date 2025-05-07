defmodule WaymarkFhirWeb.WaymarkerAuthToken do
  @moduledoc """
  Functions for generating and verifying waymarker authentication tokens.
  """

  @secret_key_base "your-secret-key-base-here"

  def sign(waymarker) do
    Phoenix.Token.sign(WaymarkFhirWeb.Endpoint, @secret_key_base, waymarker.id)
  end

  def verify(token) do
    Phoenix.Token.verify(WaymarkFhirWeb.Endpoint, @secret_key_base, token, max_age: 86400)
  end
end
