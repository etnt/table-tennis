defmodule TableTennis.App.Match do
  alias TableTennis.App.Player
  alias TableTennis.Repo
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias TableTennis.App.Player

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
    |> validate_number(:score1, greater_than_or_equal_to: 0)
    |> validate_number(:score2, greater_than_or_equal_to: 0)
    |> validate_fields_not_equal(:player1, :player2)
    |> validate_fields_not_equal(:score1, :score2)
    |> validate_player_exist(:player1)
    |> validate_player_exist(:player2)
  end

  @doc false
  defp validate_fields_not_equal(changeset, field1, field2) do
    v2 = get_field(changeset, field2)

    validate_change(changeset, field1, fn field, value ->
      if value == v2 do
        [{field, "can't be equal to #{field2}"}]
      else
        []
      end
    end)
  end

  @doc false
  defp validate_player_exist(changeset, player_field) do
    v = get_field(changeset, player_field)

    validate_change(changeset, player_field, fn field, value ->
      player_exist =
        from(p in Player, where: p.name == ^v)
        |> Repo.exists?()
      if player_exist do
        []
      else
        [{field, "player: #{value} does not exist"}]
      end
    end)
  end
end
