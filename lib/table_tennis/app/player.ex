defmodule TableTennis.App.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias TableTennis.App.Match
  alias TableTennis.Accounts.User

  schema "players" do
    field :nick, :string
    field :won, :integer, default: 0
    field :lost, :integer, default: 0
    field :rating, :integer, default: 1000

    belongs_to :user, User

    has_many :matches_as_player1, Match, foreign_key: :player1
    has_many :matches_as_player2, Match, foreign_key: :player2

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:nick])
    |> validate_required([:nick])
    |> validate_length(:nick, min: 3)
    |> unique_constraint([:nick])
  end
end
