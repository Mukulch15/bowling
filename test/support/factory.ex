defmodule Bowling.Factory do
  @moduledoc """
  Factory modules to insert data.
  """
  use ExMachina.Ecto, repo: Bowling.Repo

  def game_factory() do
    %Bowling.Schema.Game{lane: 2}
  end
end
