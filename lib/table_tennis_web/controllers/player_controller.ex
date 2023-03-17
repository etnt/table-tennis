defmodule TableTennisWeb.PlayerController do
  use TableTennisWeb, :controller

  alias TableTennis.App
  alias TableTennis.App.Player

  def index(conn, _params) do
    players = App.list_players()
    render(conn, :index, players: players)
  end

  def new(conn, _params) do
    changeset = App.change_player(%Player{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"player" => player_params}) do
    case App.create_player(player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player created successfully.")
        |> redirect(to: ~p"/players/#{player}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    player = App.get_player!(id)
    render(conn, :show, player: player)
  end

  def edit(conn, %{"id" => id}) do
    player = App.get_player!(id)
    changeset = App.change_player(player)
    render(conn, :edit, player: player, changeset: changeset)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = App.get_player!(id)

    case App.update_player(player, player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player updated successfully.")
        |> redirect(to: ~p"/players/#{player}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, player: player, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    player = App.get_player!(id)
    {:ok, _player} = App.delete_player(player)

    conn
    |> put_flash(:info, "Player deleted successfully.")
    |> redirect(to: ~p"/players")
  end
end
