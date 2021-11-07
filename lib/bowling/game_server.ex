defmodule Bowling.GameServer do
  alias Bowling.GameDetails

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:bowl, params} = msg, _from, state) do
    IO.inspect(msg)
    data = GameDetails.insert_game_detail(params)
    {:reply, data, state}
    # %{pins_left: pins_left} = GameDetails. get_last_bowl(params["game_id"])
    # if params["pins_down"] <= pins_left do
    #   data = GameDetails.insert_game_detail(params)
    #   {:reply, data, state}
    # else
    #   {:reply, %{}, state}
    # end
  end
end
