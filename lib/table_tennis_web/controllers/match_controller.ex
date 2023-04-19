defmodule TableTennisWeb.MatchController do
  use TableTennisWeb, :controller

  alias TableTennis.App
  alias TableTennis.App.Match

  import Ecto.Changeset

  require Logger

  # Controller plugs allows us to execute plugs within certain actions.
  # The plugs will be executed in this order!
  plug :authenticate, "before new,delete" when action in [:new, :delete]
  plug :valid_player, "before new" when action in [:new]
  plug :player_in_match, "before delete" when action in [:delete]


  # Require the user to be Authenticated!
  defp authenticate(conn, _) do
    case get_session(conn, :current_user) do
      nil ->
        conn
        |> put_flash(:error, "You need to be logged in!")
        |> redirect(to: ~p"/matches")
        |> halt()

      _user ->
        conn
    end
  end

  # The user must have a registered player!
  defp valid_player(conn, _) do
    cur_user = get_session(conn, :current_user)
    case App.email_to_player(cur_user.email) do
      [] ->
        conn
        |> put_flash(:error, "You need to register a player!")
        |> redirect(to: ~p"/matches")
        |> halt()

      [player] ->
        assign(conn, :cur_player_name, player.name)
    end
  end

  # Only a participant of the Match can delete it!
  defp player_in_match(%Plug.Conn{path_params: %{"id" => id}} = conn, _) do
    match = App.get_match!(id)
    cur_user = get_session(conn, :current_user)
    case App.email_to_player(cur_user.email) do
      [player] when player.name == match.player1 or
                    player.name == match.player2 ->
        conn
      _ ->
        conn
        |> put_flash(:error, "You did not participate in this match!")
        |> redirect(to: ~p"/matches")
        |> halt()
    end
  end


  # List all the matches.
  def index(conn, _params) do
    matches = App.list_matches()
    render(conn, :index, matches: matches)
  end

  # Enter the new match form.
  def new(conn, _params) do
    changeset = App.change_match(%Match{})
    cur_player_name = conn.assigns[:cur_player_name]
    opponents = for p <- App.list_players(), p.name != cur_player_name, do: p.name
    render(conn, :new,
      changeset: changeset,
      opponents: opponents,
      cur_player_name: [cur_player_name])
  end

  # Create a match from the issued form.
  def create(conn, %{"match" => match_params}) do
    case App.create_match(match_params) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: ~p"/matches")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render(:new, changeset: changeset)
    end
  end

  # Delete a match.
  def delete(conn, %{"id" => id}) do
    Logger.info("deleting match, id=#{id}")
    match = App.get_match!(id)
    {:ok, _match} = App.delete_match(match)

    conn
    |> put_flash(:info, "Match deleted successfully.")
    |> redirect(to: ~p"/matches")
  end


  # THE CODE BELOW IS NOT REALLY USED ANYMORE

  def show(conn, %{"id" => id}) do
    match = App.get_match!(id)
    render(conn, :show, match: match)
  end

  def edit(conn, %{"id" => id}) do
    match = App.get_match!(id)
    changeset = App.change_match(match)
    render(conn, :edit, match: match, changeset: changeset)
  end

  def update(conn, %{"id" => id, "match" => match_params}) do
    match = App.get_match!(id)

    case App.update_match(match, match_params) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match updated successfully.")
        |> redirect(to: ~p"/matches/#{match}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, match: match, changeset: changeset)
    end
  end
end
