defmodule Bowling.Repo.Migrations.AddGamesTable do
  use Ecto.Migration

  def change do
    create table("games") do
      add :lane, :integer
      add :total_score, :integer
      timestamps()
    end
  end
end
