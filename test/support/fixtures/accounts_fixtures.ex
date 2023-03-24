defmodule TableTennis.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TableTennis.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        avatar: "some avatar",
        email: "some email",
        name: "some name",
        uid: "some uid"
      })
      |> TableTennis.Accounts.create_user()

    user
  end
end
