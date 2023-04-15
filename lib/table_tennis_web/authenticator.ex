defmodule TableTennisWeb.Authenticator do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
      conn
      |> get_session(:current_user)
      |> case do
        nil ->
             assign(conn, :current_user, nil)
        id ->
             assign(conn, :current_user, id)
      end
  end
end
