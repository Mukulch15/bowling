defmodule Bowling.GameServer do
  alias Bowling.GameDetails
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, {0, 10, 1, 0}, name: __MODULE__)
  end

  def init(_) do
    game = GameDetails.get_latest_game()
    state = fetch_last_game_details(game)
    {:ok, state}
  end

  @doc """
    s = score
    n = total pins down within a frame
    f = frame number
    t = try number within the frame
  """
  def handle_call({:bowl, pins, game_id}, _from, state) do
    {s, n, f, t} = state
    save_game_state(pins, f, t, game_id)

    cond do
      t + 1 == 3 ->
        {:reply, {s + pins, f, t}, {s + pins, 10, f + 1, 0}}

      n - pins > 0 and t + 1 == 2 ->
        {:reply, {s + pins, f, t}, {s + pins, 10, f + 1, 0}}

      n - pins == 0 ->
        {:reply, {s + 10, f, t}, {s + 10, 10, f, t + 1}}

      n - pins < 10 ->
        {:reply, {s + pins, f, t}, {s + pins, n - pins, f, t + 1}}
    end
  end

  def handle_call(:debug, _from, state) do
    IO.inspect(state)
    {:reply, :ok, state}
  end

  def handle_call(:clear, _from, _state) do
    {:reply, :ok, {0, 10, 1, 0}}
  end

  defp fetch_last_game_details([]) do
    {0, 10, 1, 0}
  end

  defp fetch_last_game_details([head | _tails] = lst) do
    s = GameDetails.get_latest_game_score(head.game_id)
     _fetch_last_game_details(s, lst)
  end

  defp _fetch_last_game_details(_score, [head | _tails]) when head.frame == 10 and head.try == 2 do
    {0, 10, 1, 0}
  end

  defp _fetch_last_game_details(score, [head | _tails]) when head.try == 2 do
    {score, 10, head.frame + 1, 0}
  end

  defp _fetch_last_game_details(score, [head | _tails]) when head.try == 0 do
    n = if head.pins == 10, do: 10, else: 10 - head.pins
    {score, n, head.frame, 1}
  end

  defp _fetch_last_game_details(score, [head | [try0 | _tails]])
       when head.try == 1 and (head.pins + try0.pins == 10 or head.pins == 10) do
    {score, 10, head.frame, 2}
  end

  defp _fetch_last_game_details(score, [head | _]) do
    {score, 10, head.frame + 1, 0}
  end

  # defp fetch_last_game_details([head | tails]) do
  #   s = GameDetails.get_latest_game_score(head.game_id)

  #   cond do
  #     head.frame == 10 and head.try == 2 ->
  #       {0, 10, 1, 0}

  #     head.try == 2 ->
  #       {s, 10, head.frame + 1, 0}

  #     head.try == 0 ->
  #       n = if head.pins == 10, do: 10, else: 10 - head.pins
  #       {s, n, head.frame, 1}

  #     head.try == 1 and head.pins == 10 ->
  #       [try0 | _x] = tails
  #       {s, 10, head.frame, 2}

  #     head.try == 1 and head.pins + try0.pins == 10 ->
  #       [try0 | _x] = tails
  #       {s, 10, head.frame, 2}

  #     true ->
  #       {s, 10, head.frame + 1, 0}
  #       # cond do
  #       #   head.pins == 10 ->
  #       #     {s, 10, head.frame, 2}

  #       #   head.pins + try0.pins == 10 ->
  #       #     {s, 10, head.frame, 2}

  #       #   true ->
  #       #     {s, 10, head.frame + 1, 0}
  #       # end
  #   end
  # end

  defp save_game_state(n, f, t, game_id) do
    GameDetails.insert_game_detail(%{"pins" => n, "frame" => f, "try" => t, "game_id" => game_id})
  end
end
