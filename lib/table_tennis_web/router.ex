defmodule TableTennisWeb.Router do
  use TableTennisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TableTennisWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TableTennisWeb.Authenticator
  end


  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", TableTennisWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    #delete "/logout", AuthController, :delete
  end

  scope "/", TableTennisWeb do
    pipe_through :browser

    get "/", PageController, :home
    resources "/players", PlayerController, only: [:index, :new, :create, :delete]
    resources "/matches", MatchController, only: [:index, :new, :create, :update, :delete]
    resources "/users", UserController
    get "/logout", AuthController, :delete
    get "/login", PageController, :login
  end


  # Other scopes may use custom stacks.
  # scope "/api", TableTennisWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:table_tennis, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TableTennisWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
