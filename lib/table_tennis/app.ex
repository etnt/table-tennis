defmodule TableTennis.App do
  @moduledoc """
  The App context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias TableTennis.Repo

  alias TableTennis.App.Player

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    # Repo.all(Player)
    Repo.all(from p in Player, order_by: [desc: p.rating])
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  alias TableTennis.App.Match

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Repo.all(Match)
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id)

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_match(attrs \\ %{}) do
    changeset =
      %Match{}
      |> Match.changeset(attrs)
      |> IO.inspect(label: "data")
      |> update_player_stats()
      |> Repo.insert()
  end

  defp update_player_stats(changeset) do
    if changeset.valid? do
      {wp, lp} =
        if changeset.changes.score1 > changeset.changes.score2 do
          {changeset.changes.player1, changeset.changes.player2}
        else
          {changeset.changes.player2, changeset.changes.player1}
        end

      # Increment the 'won' field of the winning player
      update_winning_won = from(p in Player, where: p.name == ^wp, update: [inc: [won: 1]])

      # Increment the 'lost' field of the loosing player
      update_loosing_lost = from(p in Player, where: p.name == ^lp, update: [inc: [lost: 1]])

      Ecto.Multi.new()
      |> Ecto.Multi.update_all(:winning_won, update_winning_won, [])
      |> Ecto.Multi.run(:check_won, fn
        _repo, %{winning_won: {1, _}} -> {:ok, nil}
        _repo, %{winning_won: {_, _}} -> {:error, {:failed_won, wp}}
      end)
      |> Ecto.Multi.update_all(:loosing_lost, update_loosing_lost, [])
      |> Repo.transaction()
      |> case do
        {:ok, _} ->
          # Handle success case
          :ok

        {:error, name, value, changes_so_far} ->
          # Handle failure case
          :error
      end

      # FIXA SÅ ATT update_rating OXÅ JOBBAR MOT Ecto.Multi
      # SE TILL ATT RETURNERA CHANGESET "error" TILL MATCH-CONTROLLERN!

      winner =
        Repo.one!(from p in Player, where: p.name == ^wp, select: [:name, :rating])
        |> IO.inspect(label: "winner")

      loser =
        Repo.one!(from p in Player, where: p.name == ^lp, select: [:name, :rating])
        |> IO.inspect(label: "loser")

      update_rating(winner, loser)
    end

    changeset
  end

  @doc """
  Updates the player ratings.

  This code was actually produced py Chat-GPT...
  """
  defp update_rating(winner, loser) do
    wname = winner.name
    lname = loser.name

    winner_rating = winner.rating
    loser_rating = loser.rating

    expected_score_winner = expected_score(winner_rating, loser_rating)
    expected_score_loser = expected_score(loser_rating, winner_rating)

    k_factor_winner = k_factor(winner_rating)
    k_factor_loser = k_factor(loser_rating)

    updated_winner_rating = round(winner_rating + k_factor_winner * (1 - expected_score_winner))

    updated_loser_rating = round(loser_rating + k_factor_loser * (0 - expected_score_loser))

    from(p in Player, where: p.name == ^wname, update: [set: [rating: ^updated_winner_rating]])
    |> Repo.update_all([])

    from(p in Player, where: p.name == ^lname, update: [set: [rating: ^updated_loser_rating]])
    |> Repo.update_all([])
  end

  defp expected_score(rating, opponent_rating) do
    1 / (1 + :math.pow(10, (opponent_rating - rating) / 400))
  end

  defp k_factor(rating) do
    case rating do
      rating when rating < 2400 -> 32
      rating when rating >= 2400 -> 16
    end
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end
end
