defmodule TableTennisWeb.MatchController do
  use TableTennisWeb, :controller

  alias TableTennis.App
  alias TableTennis.App.Match

  require Logger

  def index(conn, _params) do
    matches = App.list_matches()
    cur_user = get_session(conn, :current_user)
    conn
    |> render(:index, matches: matches, current_user: cur_user)
  end

  def new(conn, _params) do
    changeset = App.change_match(%Match{})
    cur_user = get_session(conn, :current_user)
    conn
    |> render(:new, changeset: changeset, current_user: cur_user)
  end

  def create(conn, %{"match" => match_params}) do
    case App.create_match(match_params) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: ~p"/matches/#{match}")

      {:error, %Ecto.Changeset{} = changeset} ->
        cur_user = get_session(conn, :current_user)
        conn
        |> render(:new, changeset: changeset, current_user: cur_user)
    end
  end

  def show(conn, %{"id" => id}) do
    match = App.get_match!(id)
    cur_user = get_session(conn, :current_user)
    conn
    |> render(:show, match: match, current_user: cur_user)
  end

  def edit(conn, %{"id" => id}) do
    match = App.get_match!(id)
    changeset = App.change_match(match)
    cur_user = get_session(conn, :current_user)
    conn
    |> render(:edit, match: match, changeset: changeset, current_user: cur_user)
  end

  def update(conn, %{"id" => id, "match" => match_params}) do
    match = App.get_match!(id)

    case App.update_match(match, match_params) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match updated successfully.")
        |> redirect(to: ~p"/matches/#{match}")

      {:error, %Ecto.Changeset{} = changeset} ->
        cur_user = get_session(conn, :current_user)
        conn
        |> render(:edit, match: match, changeset: changeset, current_user: cur_user)
    end
  end

  def delete(conn, %{"id" => id}) do
    Logger.info "deleting match, id=#{id}"
    match = App.get_match!(id)
    {:ok, _match} = App.delete_match(match)

    conn
    |> put_flash(:info, "Match deleted successfully.")
    |> redirect(to: ~p"/matches")
  end
end
