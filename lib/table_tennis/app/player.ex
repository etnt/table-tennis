defmodule TableTennis.App.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :lost, :integer, default: 0
    field :name, :string
    field :rating, :integer, default: 1000
    field :won, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    # |> cast(attrs, [:name, :won, :lost, :rating])
    |> cast(attrs, [:name])
    # |> validate_required([:name, :won, :lost, :rating])
    |> validate_required([:name])
    |> validate_length(:name, min: 3)
    |> unique_constraint([:name])
  end
end
