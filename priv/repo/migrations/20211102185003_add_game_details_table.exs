defmodule Bowling.Repo.Migrations.AddGameDetailsTable do
  use Ecto.Migration

  def change do
    create table("game_details") do
      add :pins, :integer
      add :frame, :integer
      add :try_no, :integer
      add :next_frame, :integer
      add :next_try, :integer
      add :pins_left, :integer
      add :game_id, references("games")
      timestamps()
    end
  end
end
