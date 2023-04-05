defmodule TableTennis.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string
      add :won, :integer
      add :lost, :integer
      add :rating, :integer
      add :email, :string

      timestamps()
    end

    create unique_index(:players, [:name])
    create unique_index(:players, [:email])
  end
end
