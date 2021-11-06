defmodule Bowling.Games do
  @moduledoc false
  alias Bowling.GameServer
  alias Bowling.Schema.Game
  alias Bowling.Repo

  import Ecto.Query

  def create_game(params) do
    %{lane: params["lane"]}
    |> Game.changeset()
    |> Repo.insert()
  end
end
