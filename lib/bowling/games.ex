defmodule Bowling.Games do
  @moduledoc false
  alias Bowling.Schema.Game
  alias Bowling.Repo

  def create_game(params) do
    changeset = Game.changeset(%{lane: params["lane"]})

    case changeset do
      %Ecto.Changeset{valid?: true} ->
        Repo.insert(changeset)

      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)}
    end
  end
end
