defmodule BowlingWeb.GameController do
  alias Bowling.Games
  alias Bowling.GameDetails
  alias Bowling.GameServer
  use BowlingWeb, :controller

  def create(conn, params) do
    {:ok, game} = Games.create_game(params)
    json(conn, %{game_id: game.id, pins_left: 10, try_no: 1, frame: 1})
  end

  def bowl(conn, params) do
    case GameDetails.insert_game_detail(params) do
      :error ->
        conn
        |> put_status(400)
        |> json(%{error: "incorrect request"})

      data ->
        json(conn, data)
    end
  end

  def get_score(conn, params) do
    res = GameDetails.game_scores(params["game_id"])
    json(conn, %{res: res})
  end
end
