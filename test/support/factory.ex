defmodule Bowling.Factory do
  @moduledoc """
  Factory modules to insert data.
  """
  use ExMachina.Ecto, repo: Bowling.Repo

  def game_factory() do
    %Bowling.Schema.Game{lane: 2}
  end

  def game_detail_factory(params) do
    %Bowling.Schema.GameDetail{
      pins: params.pins,
      frame: params.frame,
      try_no: params.try_no,
      next_frame: params.next_frame,
      next_try: params.next_try,
      pins_left: params.pins_left,
      game_id: params.game_id
    }
  end
end
