defmodule TableTennisWeb.Authenticator do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user =
      conn
      |> get_session(:current_user)
      |> case do
        nil -> nil
        id -> id
      end

    assign(conn, :current_user, user)
  end
end
