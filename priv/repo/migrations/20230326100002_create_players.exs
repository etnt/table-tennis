defmodule TableTennis.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :nick, :string
      add :won, :integer
      add :lost, :integer
      add :rating, :integer

      add :user_id, references("users", on_delete: :delete_all)

      add :matches_as_player1, references("matches", foreign_key: :player1)
      add :matches_as_player2, references("matches", foreign_key: :player2)

      timestamps()
    end

    create unique_index(:players, [:nick])
  end
end
