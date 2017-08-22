defmodule Collaboration.Router do
  use Collaboration.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Collaboration.Auth, repo: Collaboration.Repo
    plug Collaboration.ImportData
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

    # Topics
    resources "/topics", TopicController

    # Ideas
    resources "/ideas", IdeaController

    #admin
    resources "/admin", AdminController, only: [:index, :update]
    get "/admin/instructions", AdminController, :instructions
    get "/admin/topics", AdminController, :topics
    get "/admin/users", AdminController, :users
  end
end
