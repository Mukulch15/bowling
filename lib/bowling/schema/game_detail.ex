defmodule Bowling.Schema.GameDetail do
  alias Bowling.Schema.Game
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "game_details" do
    field :pins, :integer
    field :frame, :integer
    field :try, :integer
    belongs_to :games, Game, foreign_key: :game_id
    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:pins, :frame, :try, :game_id])
    |> validate_required([:pins, :frame, :try, :game_id])
  end
end
