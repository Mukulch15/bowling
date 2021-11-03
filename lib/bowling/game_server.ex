defmodule Bowling.GameServer do
  alias Bowling.GameDetail
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__,{0, 10, 1, 0}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  @doc """
    s = score
    n = total pins down within a frame
    f = frame number
    t = try number within the frame
  """
  def handle_cast({:bowl, pins, game_id}, state) do
    {s, n, f, t} = state
    save_game_state(pins, f, t, game_id)
    cond do
      t + 1 == 3 ->
        {:noreply, {s + pins,10, f + 1, 0}}
      (n - pins > 0) and (t + 1 == 2) ->
        {:noreply, {s + pins, 10, f + 1, 0}}
      (n - pins == 0) ->
        {:noreply, {s + 10, 10, f, t + 1}}
      (n - pins < 10) ->
        {:noreply, {s + pins, n - pins, f, t + 1}}

    end
  end

  def handle_call(:debug, from, state) do
    IO.inspect state
    {:reply, :ok, state}

  end

  defp save_game_state(n, f, t, game_id) do
    game_detail = %GameDetail{pins: n, frame: f, try: t, game_id: game_id}
    Bowling.Repo.insert(game_detail)
  end
end
