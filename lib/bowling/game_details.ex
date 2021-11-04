defmodule Bowling.GameDetails do
  alias Bowling.Games
  alias Bowling.Repo
  alias Bowling.Schema.GameDetail
  import Ecto.Query

  use Ecto.Schema

  def insert_game_detail(params) do
    # game = Games.get_game(params["game_id"])
    # game_details = GameDetail.changeset( %{pins: params["pins"], frame: params["frame"], try: params["try"]})
    # game
    # |>Ecto.build_assoc(:game_details, game_details)
    GameDetail.changeset(%{
      pins: params["pins"],
      frame: params["frame"],
      try: params["try"],
      game_id: params["game_id"]
    })
    |> Repo.insert()
  end

  def get_latest_game() do
    latest_game =
      GameDetail
      |> select([u], u)
      |> order_by(desc: :updated_at)
      |> limit(3)
      |> Repo.all()
  end

  def get_latest_game_score(game_id) do
    GameDetail
    |> select([u], sum(u.pins))
    |> where([u], u.game_id == ^game_id)
    |> Repo.one()
  end

  def get_all_frame_score(game_id) do
    GameDetail
    |> group_by([u], u.frame)
    |> select([u], %{score: sum(u.pins), frame: u.frame})
    |> where([u], u.game_id == ^game_id)
    |> Repo.all()
  end
end
