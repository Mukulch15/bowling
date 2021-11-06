defmodule Bowling.Schema.Game do
  @moduledoc """
   Schema for game
  """
  alias Bowling.Schema.GameDetail
  import Ecto.Changeset

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "games" do
    field :lane, :integer
    timestamps()
    has_many :game_details, GameDetail
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:lane])
    |> validate_required([:lane])
  end

  def update_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:id])
    |> validate_required([:id])
  end
end
