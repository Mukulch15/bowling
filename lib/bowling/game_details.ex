defmodule Bowling.GameDetails do
  @moduledoc """
    This is the main module that deals with persistence of each bowling state into the database
    and ets.
    Each bowling action is reperesnted by the following state:
    pins | frame | try_no | next_frame | next_try | pins_left

    Example - If it is second try and the player still hasn't knocked down all the pins
    next_frame wil be frame + 1 and next_try will be set to 1

    pins_left is the number of pins left after each bowl

    There are two ets tables :current_frame and :frame_scores

    Example of a game in db:
        pins | frame | try_no | next_frame | next_try | pins_left
    ------+-------+--------+------------+----------+-----------
        4 |     1 |      1 |          1 |        2 |         6
        4 |     1 |      2 |          2 |        1 |        10
       10 |     2 |      1 |          2 |        2 |        10
       10 |     2 |      2 |          2 |        3 |        10
       10 |     2 |      3 |          3 |        1 |        10
  """
  alias Bowling.Repo
  alias Bowling.Schema.GameDetail
  import Ecto.Query

  use Ecto.Schema

  @doc """
    This function deals with each bowling action, determining the next state and saving it in db and ets for caching.
    Validations:
    1. If pins knocked is > pins left then it will respond with bad_request.
    2. If the next frame has reached 11 then it means that the game is over and display the score.
    3. All the bowl and the frame and score is persisted into ets as well so that score calculation is performant.
  """
  def insert_game_detail(params) do
    %{"pins_down" => pins_down, "game_id" => game_id} = params

    %{pins_left: pins_left, pins: previous_bowl, next_frame: frame, next_try: try_no} =
      get_last_bowl(game_id)

    cond do
      # Display score once the next_frame is more than 10
      frame > 10 ->
        game_scores(params["game_id"])

      pins_left >= pins_down ->
        {pins_left, next_frame, next_try} =
          cond do
            # If try no is 3 then reset the variables and increase frame number
            try_no == 3 ->
              {10, frame + 1, 1}

            # If it is try no 2 and player hasn't knocked down all the pins in the alley. Then reset and increase frame by 1.
            pins_down + previous_bowl < 10 and try_no == 2 ->
              {10, frame + 1, 1}

            # If the player knocked all the pins then only increae try no 'cause he will get another chance,
            pins_left - pins_down == 0 ->
              {10, frame, try_no + 1}

            # For all other cases increase the try_no and update pins left.
            true ->
              {pins_left - pins_down, frame, try_no + 1}
          end

        :ets.insert(:frame_scores, {game_id, {frame, pins_down}})
        :ets.insert(:current_frame, {game_id, next_frame})

        GameDetail.changeset(%{
          pins: pins_down,
          frame: frame,
          try_no: try_no,
          next_frame: next_frame,
          next_try: next_try,
          pins_left: pins_left,
          game_id: game_id
        })
        |> Repo.insert()

        if next_frame > 10,
          do: game_scores(params["game_id"]),
          else: %{pins_left: pins_left, next_frame: next_frame, next_try: next_try}

      true ->
        :error
    end
  end

  def get_completed_frame(game_id) do
    case :ets.lookup(:current_frame, game_id) do
      [] ->
        1

      [{^game_id, res}] = _data ->
        res
    end
  end

  @doc """
  Auxillary function that gives us important details of the previous bowl for validations.
  """
  def get_last_bowl(game_id) do
    last_bowl =
      GameDetail
      |> select([u], u)
      |> where([u], u.game_id == ^game_id)
      |> order_by([u], desc: :inserted_at)
      |> limit(1)
      |> Repo.one()

    if is_nil(last_bowl) do
      %{pins_left: 10, pins: 0, next_frame: 1, next_try: 1}
    else
      last_bowl
    end
  end

  @doc """
  This function is used to recover the exact state of the game in ets in case the application crashes.
  """
  def recover_latest_game_state() do
    case get_latest_game() do
      {next_frame, game_id} ->
        :ets.insert(:current_frame, {game_id, next_frame})

        if next_frame == 11 do
          :ok
        else
          data = get_all_frame_states(game_id)

          Enum.each(data, fn x ->
            :ets.insert(:frame_scores, {game_id, {x.frame, x.pins}})
          end)
        end

      _ ->
        :ok
    end
  end

  @doc """
    Calculates the total game score and each frame score.
  """
  def game_scores(game_id) do
    current_frame = get_completed_frame(game_id)

    frame_scores =
      :frame_scores
      |> :ets.lookup(game_id)
      |> Enum.reduce(%{}, fn {_, {frame, score}}, acc ->
        if frame < current_frame do
          val = Map.get(acc, frame, 0)
          Map.put(acc, frame, score + val)
        else
          acc
        end
      end)

    total = Enum.reduce(frame_scores, 0, fn {_frame, score}, acc -> score + acc end)
    %{frame_scores: frame_scores, total: total}
  end

  # Auxillary function that fetches a map contaiing the details for each frame.
  defp get_all_frame_states(game_id) do
    GameDetail
    |> select([u], %{pins: u.pins, frame: u.frame, next_frame: u.next_frame})
    |> where([u], u.game_id == ^game_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  # Auxillary function that gives the latest bowling frame
  def get_latest_game do
    GameDetail
    |> select([u], {u.next_frame, u.game_id})
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end
end
