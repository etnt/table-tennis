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
    |> validate_number(:score1, greater_than_or_equal_to: 0)
    |> validate_number(:score2, greater_than_or_equal_to: 0)
    |> validate_fields_not_equal(:score1, :score2)
  end

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

end
