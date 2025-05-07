defmodule WaymarkFhir.Messaging.Consumer do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(_opts) do
    rabbitmq_config = Application.get_env(:waymark_fhir, :rabbitmq)
    
    connection_params = cond do
      Keyword.has_key?(rabbitmq_config, :url) -> 
        Keyword.get(rabbitmq_config, :url)
      true ->
        host = Keyword.get(rabbitmq_config, :host)
        port = Keyword.get(rabbitmq_config, :port)
        username = Keyword.get(rabbitmq_config, :username)
        password = Keyword.get(rabbitmq_config, :password)
        vhost = Keyword.get(rabbitmq_config, :virtual_host, "/")
        "amqp://#{username}:#{password}@#{host}:#{port}/#{vhost}"
    end

    {:ok, connection} = AMQP.Connection.open(connection_params)
    {:ok, channel} = AMQP.Channel.open(connection)

    queue = Keyword.get(rabbitmq_config, :queue)
    AMQP.Queue.declare(channel, queue, durable: true)
    AMQP.Basic.consume(channel, queue)

    Logger.info("Consumer started and connected to RabbitMQ")
    {:ok, %{channel: channel, connection: connection}}
  end

  @impl true
  def handle_info({:basic_deliver, payload, _meta}, state) do
    Logger.info("Received message: #{payload}")

    case Jason.decode(payload) do
      {:ok, resource} ->
        case WaymarkFhir.FHIR.Transformer.transform(resource) do
          {:ok, transformed} ->
            Logger.info("Transformed resource: #{inspect(transformed)}")
            {:noreply, state}

          {:error, reason} ->
            Logger.error("Failed to transform resource: #{inspect(reason)}")
            {:noreply, state}
        end

      {:error, reason} ->
        Logger.error("Failed to decode message: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:basic_consume_ok, _meta}, state), do: {:noreply, state}

  @impl true
  def handle_info({:basic_cancel, _}, state) do
    Logger.warning("Consumer cancelled by RabbitMQ")
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}

  @impl true
  def terminate(_reason, %{channel: channel, connection: connection}) do
    AMQP.Channel.close(channel)
    AMQP.Connection.close(connection)
  end
end
