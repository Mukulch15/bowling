defmodule Bowling.GameDetail do
  alias Bowling.Game
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "game_details" do
    field :pins, :integer
    field :frame, :integer
    field :try, :integer
    belongs_to :games, Game, foreign_key: :game_id
    timestamps()
  end
end
