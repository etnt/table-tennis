defmodule TableTennisWeb.PlayerController do
  use TableTennisWeb, :controller

  alias TableTennis.App
  alias TableTennis.App.Player
  alias TableTennis.Accounts

  # Controller plugs allows us to execute plugs only certain actions.
  plug :authenticate, "before all but index" when action not in [:index]

  defp authenticate(conn, _) do
    case conn.private.phoenix_action do
      :index ->
        conn
      _action ->
        case get_session(conn, :current_user) do
          nil ->
            conn
            |> put_flash(:error, "You need to be logged in!")
            |> redirect(to: ~p"/players")
            |> halt()
          _user ->
            conn
        end
    end
  end

  def index(conn, _params) do
    players = App.list_players()
    render(conn, :index, players: players)
  end

  def new(conn, _params) do
    cur_user = get_session(conn, :current_user)
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

  def create(conn, %{"player" => player_params}) do
    cur_user = get_session(conn, :current_user)
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
    cur_user = get_session(conn, :current_user)
    player = App.get_player!(id)

    # Remove all matches of the player!
    matches = App.list_matches_for_player(player)
    for m <- matches, do: App.delete_match(m)

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
