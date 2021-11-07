defmodule BowlingWeb.GameControllerTest do
  use BowlingWeb.ConnCase
  import Bowling.Factory

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
end
