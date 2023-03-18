defmodule TableTennis.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :player1, :string
      add :player2, :string
      add :score1, :integer
      add :score2, :integer

      timestamps()
    end
  end
end
