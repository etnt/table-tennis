defmodule TableTennis.App do
  @moduledoc """
  The App context.
  """

  import Ecto.Query, warn: false
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

  def email_to_player(email) do
    Repo.all(from p in Player, where: p.email == ^email)
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
    # Repo.all(Match)
    Repo.all(from m in Match, order_by: [desc: m.updated_at])
  end

  @doc """
  Returns the list of matches for a player.

  ## Examples

      iex> list_matches_for_player(player)
      [%Match{}, ...]

  """
  def list_matches_for_player(player) do
    name = player.name
    Repo.all(from m in Match, where: m.player1 == ^name or m.player2 == ^name)
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
    %Match{}
    |> Match.changeset(attrs)
    |> update_player_stats()
  end

  defp update_player_stats(changeset) do
    if changeset.valid? do
      result =
        Repo.transaction(fn ->
          # Figure out winning and losing player
          {wp, lp} =
            if changeset.changes.score1 > changeset.changes.score2 do
              {changeset.changes.player1, changeset.changes.player2}
            else
              {changeset.changes.player2, changeset.changes.player1}
            end

          # Increment the 'won' field of the winning player
          from(p in Player, where: p.name == ^wp, update: [inc: [won: 1]])
          |> Repo.update_all([])

          # Increment the 'lost' field of the loosing player
          from(p in Player, where: p.name == ^lp, update: [inc: [lost: 1]])
          |> Repo.update_all([])

          # Get the current rating of the winner
          winner = Repo.one!(from p in Player, where: p.name == ^wp, select: [:rating])

          # Get the current rating of the looser
          loser = Repo.one!(from p in Player, where: p.name == ^lp, select: [:rating])

          # Calculate new ratings
          {updated_winner_rating, updated_loser_rating} =
            update_rating(winner.rating, loser.rating)

          # Set a new rating for the winning player
          {1, nil} =
            from(p in Player,
              where: p.name == ^wp,
              update: [set: [rating: ^updated_winner_rating]]
            )
            |> Repo.update_all([])

          # Set a new rating for the loosing player
          {1, nil} =
            from(p in Player, where: p.name == ^lp, update: [set: [rating: ^updated_loser_rating]])
            |> Repo.update_all([])

          # Finally add the match!
          changeset
          |> Repo.insert()
        end)

      case result do
        {:ok, ok} -> ok
        _ -> {:error, changeset}
      end
    else
      {:error, changeset}
    end
  end

  # This rating calculation was actually produced py Chat-GPT...
  defp update_rating(winner_rating, loser_rating) do
    expected_score_winner = expected_score(winner_rating, loser_rating)
    expected_score_loser = expected_score(loser_rating, winner_rating)

    k_factor_winner = k_factor(winner_rating)
    k_factor_loser = k_factor(loser_rating)

    updated_winner_rating = round(winner_rating + k_factor_winner * (1 - expected_score_winner))

    updated_loser_rating = round(loser_rating + k_factor_loser * (0 - expected_score_loser))

    {updated_winner_rating, updated_loser_rating}
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
