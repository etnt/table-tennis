defmodule TableTennis.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TableTennisWeb.Telemetry,
      # Start the Ecto repository
      TableTennis.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: TableTennis.PubSub},
      # Start Finch
      {Finch, name: TableTennis.Finch},
      # Start the Endpoint (http/https)
      TableTennisWeb.Endpoint
      # Start a worker by calling: TableTennis.Worker.start_link(arg)
      # {TableTennis.Worker, arg}
    ]

    # Create an ETS table when the application starts.
    # See: @session_options in endpoint.ex
    # This to avoid too large cookie values (4096).
    :ets.new(:session, [:named_table, :public, read_concurrency: true])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TableTennis.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TableTennisWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
