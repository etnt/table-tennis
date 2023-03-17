defmodule TableTennis.Repo do
  use Ecto.Repo,
    otp_app: :table_tennis,
    adapter: Ecto.Adapters.Postgres
end
