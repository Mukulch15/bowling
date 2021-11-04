defmodule Bowling.Games do
  alias Bowling.GameServer
  alias Bowling.Schema.Game
  alias Bowling.Repo

  def create_game(params) do
    GenServer.call(GameServer, :clear)

    %{lane: params["lane"]}
    |> Game.changeset()
    |> Repo.insert()
  end

  def get_game(game_id) do
    Repo.get!(Game, game_id)
  end
end
