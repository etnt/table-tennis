defmodule TableTennis.Repo.Migrations.AddPlayerToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # Have to add this field after 'players' is created?
      add :player, references("players")
    end
  end
end
