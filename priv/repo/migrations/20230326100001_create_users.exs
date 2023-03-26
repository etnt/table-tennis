defmodule TableTennis.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :uid, :string
      add :name, :string
      add :avatar, :string

      # Have to add that after 'players' is created?
      #add :player, references("players")

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
