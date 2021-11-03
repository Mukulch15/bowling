defmodule Bowling.Game do
  alias Bowling.GameDetail
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "games" do
    field :lane, :integer
    timestamps()
    has_many :game_details, GameDetail
  end

  def changeset(game, params \\ %{}) do
    game
    |>cast(params, [:lane])
    |>validate_required([:lane])
  end
end
