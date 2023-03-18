defmodule TableTennis.App.Match do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :player1, :string
    field :player2, :string
    field :score1, :integer
    field :score2, :integer

    timestamps()
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:player1, :player2, :score1, :score2])
    |> validate_required([:player1, :player2, :score1, :score2])
  end
end
