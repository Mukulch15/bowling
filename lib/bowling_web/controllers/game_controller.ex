defmodule BowlingWeb.GameController do
  alias Bowling.Games
  use BowlingWeb, :controller

  def create(conn, params) do
    {:ok, game} = Games.create_game(params)
    json(conn, %{game_id: game.id})
  end

  def bowl(conn, params) do
    {s, f, _} = GenServer.call(Bowling.GameServer, {:bowl, params["pins"], params["game_id"]})

    if f > 10 do
      json(conn, %{status: "over", score: s})
      GenServer.call(Bowling.GameServer, :clear)
    else
      json(conn, %{})
    end
  end
end

# GenServer.cast(Bowling.GameServer, {:bowl, 8, 1})
# GenServer.call(Bowling.GameServer, :debug)
