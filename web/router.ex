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
    get "/register", UserController, :new

    # User Management
    get "/settings", UserController, :edit
    resources "/users", UserController, only: [:index, :show, :create, :edit, :delete]

  end
end
