defmodule TableTennisWeb.PlayerController do
  use TableTennisWeb, :controller

  alias TableTennis.App
  alias TableTennis.App.Player
  alias TableTennis.Accounts

  def index(conn, _params) do
    players = App.list_players()
    render(conn, :index, players: players)
  end

  def new(conn, _params) do
    case get_session(conn, :current_user) do
      nil ->
        conn
        |> put_flash(:error, "You need to be logged in!.")
        |> redirect(to: ~p"/players")

      cur_user ->
        case App.email_to_player(cur_user.email) do
          [] ->
            changeset = App.change_player(%Player{})
            render(conn, :new, changeset: changeset)
          [player] ->
            conn
            |> put_flash(:error, "Already registered as player: " <> player.name)
            |> redirect(to: ~p"/players")
        end

    end
  end

  def create(conn, %{"player" => player_params}) do
    IO.inspect(player_params, label: ">>> PlayerParams: ")
    case get_session(conn, :current_user) do
      nil ->
        conn
        |> put_flash(:error, "You need to be logged in!.")
        |> redirect(to: ~p"/players")
      cur_user ->
        case App.create_player(Map.put(player_params, "email", cur_user.email)) do
          {:ok, player} ->
            IO.inspect(player, label: ">>> NEW PLAYER: ")
            conn
            |> put_flash(:info, "Player created successfully.")
            |> redirect(to: ~p"/players")

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :new, changeset: changeset)
        end
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
    case get_session(conn, :current_user) do
      nil ->
        conn
        |> put_flash(:error, "You need to be logged in!.")
        |> redirect(to: ~p"/players")
      cur_user ->
        player = App.get_player!(id)
        if cur_user.email == player.email do
          {:ok, _player} = App.delete_player(player)
          conn
          |> put_flash(:info, "Player deleted successfully.")
          |> redirect(to: ~p"/players")
        else
          conn
          |> put_flash(:error, "You have not created that player!.")
          |> redirect(to: ~p"/players")
        end
    end
  end
end
