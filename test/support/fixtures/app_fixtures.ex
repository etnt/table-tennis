defmodule TableTennis.AppFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TableTennis.App` context.
  """

  @doc """
  Generate a player.
  """
  def player_fixture(attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        lost: 42,
        name: "some name",
        rating: 42,
        won: 42
      })
      |> TableTennis.App.create_player()

    player
  end
end
