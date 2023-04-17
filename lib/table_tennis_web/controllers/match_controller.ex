defmodule TableTennisWeb.MatchController do
  use TableTennisWeb, :controller

  alias TableTennis.App
  alias TableTennis.App.Match

  import Ecto.Changeset

  require Logger

  # Controller plugs allows us to execute plugs only within certain actions.
  plug :valid_player, "before new" when action in [:new]

  # A new match can only be created by a registered Player.
  defp valid_player(conn, _) do
    cur_user = get_session(conn, :current_user)
    case App.email_to_player(cur_user.email) do
      [] ->
        conn
        |> put_flash(:error, "You need to register a player!")
        |> redirect(to: ~p"/matches")
        |> halt()

      [player] ->
        IO.inspect(player, label: ">>>> player")
        assign(conn, :cur_player_name, player.name)
    end
  end


  def index(conn, _params) do
    matches = App.list_matches()
    render(conn, :index, matches: matches)
  end

  def new(conn, _params) do
    changeset = App.change_match(%Match{})
    cur_player_name = conn.assigns[:cur_player_name]
    IO.inspect(cur_player_name, label: ">>>> cur player name")
    opponents = for p <- App.list_players(), p.name != cur_player_name, do: p.name
    IO.inspect(opponents, label: ">>>> opponents")
    render(conn, :new, changeset: changeset, opponents: opponents, cur_player_name: [cur_player_name])
  end

  def create(conn, %{"match" => match_params}) do
    case App.create_match(match_params) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: ~p"/matches")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

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

  def delete(conn, %{"id" => id}) do
    Logger.info("deleting match, id=#{id}")
    match = App.get_match!(id)
    {:ok, _match} = App.delete_match(match)

    conn
    |> put_flash(:info, "Match deleted successfully.")
    |> redirect(to: ~p"/matches")
  end
end
