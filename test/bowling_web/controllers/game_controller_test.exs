defmodule BowlingWeb.GameControllerTest do
  use BowlingWeb.ConnCase
  import Bowling.Factory

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bowling.Repo)
  end

  describe "POST /game" do
    test "Successful game creation", %{conn: conn} do
      conn = post(conn, "/game", %{lane: 1})
      json_response(conn, 200)

      assert %{
               "frame" => 1,
               "game_id" => _game_id,
               "pins_left" => 10,
               "try_no" => 1
             } = json_response(conn, 200)
    end

    test "Error in game creation in case of incorrect params", %{conn: conn} do
      conn = post(conn, "/game")
      json_response(conn, 400)

      assert %{
               "error" => %{"lane" => ["can't be blank"]}
             } = json_response(conn, 400)
    end
  end

  describe "POST /game/bowl" do
    setup do
      game = insert(:game)
      %{game: game}
    end

    test "First try successful", %{conn: conn, game: game} do
      conn = post(conn, "/game/bowl", %{game_id: game.id, pins_down: 1})
      json_response(conn, 200)

      assert %{
               "next_frame" => 1,
               "next_try" => 2,
               "pins_left" => 9
             } = json_response(conn, 200)
    end

    test "Try unsuccessful if number of pins down is more than pins left", %{
      conn: conn,
      game: game
    } do
      conn = post(conn, "/game/bowl", %{game_id: game.id, pins_down: 11})
      assert %{} = json_response(conn, 400)
    end

    test "Player gets third try in case of strike", %{conn: conn, game: game} do
      insert(:game_detail, %{
        pins: 10,
        frame: 1,
        try_no: 1,
        next_frame: 1,
        next_try: 2,
        pins_left: 10,
        game_id: game.id
      })

      json =
        conn
        |> post("/game/bowl", %{game_id: game.id, pins_down: 3})
        |> json_response(200)

      assert %{"next_frame" => 1, "next_try" => 3, "pins_left" => 7} == json
    end

    test "Game gets to next frame if it's an open", %{conn: conn, game: game} do
      insert(:game_detail, %{
        pins: 4,
        frame: 1,
        try_no: 1,
        next_frame: 1,
        next_try: 2,
        pins_left: 6,
        game_id: game.id
      })

      json =
        conn
        |> post("/game/bowl", %{game_id: game.id, pins_down: 2})
        |> json_response(200)

      assert %{"next_frame" => 2, "next_try" => 1, "pins_left" => 10} == json
    end

    test "Player gets third try in case of spare", %{conn: conn, game: game} do
      insert(:game_detail, %{
        pins: 4,
        frame: 1,
        try_no: 1,
        next_frame: 1,
        next_try: 2,
        pins_left: 6,
        game_id: game.id
      })

      json =
        conn
        |> post("/game/bowl", %{game_id: game.id, pins_down: 6})
        |> json_response(200)

      assert %{"next_frame" => 1, "next_try" => 3, "pins_left" => 10} == json
    end

    test "Give game score once all ten frames are over", %{conn: conn, game: game} do
      insert(:game_detail, %{
        pins: 10,
        frame: 10,
        try_no: 2,
        next_frame: 10,
        next_try: 3,
        pins_left: 10,
        game_id: game.id
      })

      :ets.insert(:frame_scores, {game.id, {10, 10}})

      json =
        conn
        |> post("/game/bowl", %{game_id: game.id, pins_down: 6})
        |> json_response(200)

      assert %{"frame_scores" => %{"10" => 16}, "total" => 16} == json
    end
  end

  describe "GET /game/scores" do
    setup do
      game = insert(:game)
      %{game: game}
    end

    test "fetch game scores", %{conn: conn, game: game} do
      :ets.insert(:frame_scores, {game.id, {10, 10}})
      :ets.insert(:current_frame, {game.id, 11})

      json =
        conn
        |> get("/game/scores", %{game_id: game.id})
        |> json_response(200)

      assert %{"scores" => %{"frame_scores" => %{"10" => 10}, "total" => 10}} == json
    end
  end
end
