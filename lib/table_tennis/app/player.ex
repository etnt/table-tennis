defmodule TableTennis.App.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :lost, :integer
    field :name, :string
    field :rating, :integer
    field :won, :integer

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :won, :lost, :rating])
    |> validate_required([:name, :won, :lost, :rating])
  end
end
