defmodule Bowling.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Bowling.Repo,
      # Start the Telemetry supervisor
      BowlingWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bowling.PubSub},
      # Start the Endpoint (http/https)
      BowlingWeb.Endpoint,
      {Bowling.GameServer, []}
      # Start a worker by calling: Bowling.Worker.start_link(arg)
      # {Bowling.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bowling.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BowlingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
