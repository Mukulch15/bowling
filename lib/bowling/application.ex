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
      {Bowling.GameServer, []},
      # Start the Endpoint (http/https)
      BowlingWeb.Endpoint
      # Start a worker by calling: Bowling.Worker.start_link(arg)
      # {Bowling.Worker, arg}
    ]

    # :ets.new(:game_details, [:public, :set, :named_table])
    :ets.new(:current_frame, [:public, :set, :named_table])
    :ets.new(:frame_scores, [:public, :duplicate_bag, :named_table])
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bowling.Supervisor]
    apps = Supervisor.start_link(children, opts)
    Bowling.GameDetails.recover_latest_game_state()
    apps
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BowlingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
