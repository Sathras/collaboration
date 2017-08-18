defmodule Collaboration.Router do
  use Collaboration.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Collaboration.Auth, repo: Collaboration.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Collaboration do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    # Authentification
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete

    # User Management
    get "/register", UserController, :new
    get "/settings", UserController, :edit
    resources "/users", UserController, only: [:create, :edit, :new, :show, :update]
  end

  # Admin Level
  scope "/admin", Collaboration do
    pipe_through [:browser, :auth_admin]

    resources "/", AdminController
  end
end
