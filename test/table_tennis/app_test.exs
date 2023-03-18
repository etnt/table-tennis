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

  describe "matches" do
    alias TableTennis.App.Match

    import TableTennis.AppFixtures

    @invalid_attrs %{player1: nil, player2: nil, score1: nil, score2: nil}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert App.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert App.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = %{player1: "some player1", player2: "some player2", score1: 42, score2: 42}

      assert {:ok, %Match{} = match} = App.create_match(valid_attrs)
      assert match.player1 == "some player1"
      assert match.player2 == "some player2"
      assert match.score1 == 42
      assert match.score2 == 42
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = App.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      update_attrs = %{player1: "some updated player1", player2: "some updated player2", score1: 43, score2: 43}

      assert {:ok, %Match{} = match} = App.update_match(match, update_attrs)
      assert match.player1 == "some updated player1"
      assert match.player2 == "some updated player2"
      assert match.score1 == 43
      assert match.score2 == 43
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = App.update_match(match, @invalid_attrs)
      assert match == App.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = App.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> App.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = App.change_match(match)
    end
  end
end
