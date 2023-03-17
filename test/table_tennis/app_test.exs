defmodule TableTennis.AppTest do
  use TableTennis.DataCase

  alias TableTennis.App

  describe "players" do
    alias TableTennis.App.Player

    import TableTennis.AppFixtures

    @invalid_attrs %{lost: nil, name: nil, rating: nil, won: nil}

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert App.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert App.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      valid_attrs = %{lost: 42, name: "some name", rating: 42, won: 42}

      assert {:ok, %Player{} = player} = App.create_player(valid_attrs)
      assert player.lost == 42
      assert player.name == "some name"
      assert player.rating == 42
      assert player.won == 42
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = App.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      update_attrs = %{lost: 43, name: "some updated name", rating: 43, won: 43}

      assert {:ok, %Player{} = player} = App.update_player(player, update_attrs)
      assert player.lost == 43
      assert player.name == "some updated name"
      assert player.rating == 43
      assert player.won == 43
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = App.update_player(player, @invalid_attrs)
      assert player == App.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = App.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> App.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = App.change_player(player)
    end
  end
end
