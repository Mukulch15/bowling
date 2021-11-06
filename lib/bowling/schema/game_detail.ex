defmodule Bowling.Schema.GameDetail do
  @moduledoc """
   Schema for game detail
  """
  alias Bowling.Schema.Game
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_fields [:pins, :frame, :try_no, :game_id, :next_frame, :pins_left, :next_try]
  schema "game_details" do
    field :pins, :integer
    field :frame, :integer
    field :try_no, :integer
    field :next_frame, :integer
    field :next_try, :integer
    field :pins_left, :integer
    belongs_to :games, Game, foreign_key: :game_id
    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
