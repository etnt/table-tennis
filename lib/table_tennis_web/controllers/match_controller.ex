defmodule TableTennisWeb.MatchController do
  use TableTennisWeb, :controller

  alias TableTennis.App
  alias TableTennis.App.Match

  require Logger

  def index(conn, _params) do
    matches = App.list_matches()
    cur_user = get_session(conn, :current_user)
    conn
    |> assign(:current_user, cur_user)
    |> IO.inspect(label: "match_controller, index")
    |> render(:index, matches: matches)
  end

  def new(conn, _params) do
    changeset = App.change_match(%Match{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"match" => match_params}) do
    case App.create_match(match_params) do
      {:ok, match} ->
        conn
        |> put_flash(:info, "Match created successfully.")
        |> redirect(to: ~p"/matches/#{match}")

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
    Logger.info "deleting match, id=#{id}"
    match = App.get_match!(id)
    {:ok, _match} = App.delete_match(match)

    conn
    |> put_flash(:info, "Match deleted successfully.")
    |> redirect(to: ~p"/matches")
  end
end
