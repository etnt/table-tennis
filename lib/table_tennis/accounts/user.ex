defmodule TableTennis.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias TableTennis.App.Player

  schema "users" do
    field :avatar, :string
    field :email, :string
    field :name, :string
    field :uid, :string

    has_one :player, Player

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :avatar])
    |> validate_required([:email, :name, :avatar])
  end
end
