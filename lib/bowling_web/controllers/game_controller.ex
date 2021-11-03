defmodule BowlingWeb.GameController do
  alias Bowling.Game
  alias Bowling.Repo
  use BowlingWeb, :controller

  def create(conn, params) do
    {:ok, game} = Repo.insert(%Game{lane: params["lane"]})
    json(conn, %{game_id: game.id})
  end

  def bowl(conn, params) do
    GenServer.cast(Bowling.GameServer, {:bowl, params["pins"], params["game_id"]})
    json(conn, %{})
  end
end

#GenServer.cast(Bowling.GameServer, {:bowl, 8, 1})
#GenServer.call(Bowling.GameServer, :debug)
