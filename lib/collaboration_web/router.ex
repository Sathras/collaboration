defmodule CollaborationWeb.Router do
  use CollaborationWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CollaborationWeb.Auth
  end

  # admin routes
  scope "/", CollaborationWeb do
    pipe_through [ :browser, :authenticate_user, :authenticate_admin ]

    resources "/topics", TopicController,
      only: [:index, :new, :create, :edit, :update]
    resources "/users",  UserController, only: [:index, :update]
    post "/feature/:id", TopicController, :feature
    get "/participants", UserController, :participants
  end

  # protected routes
  scope "/", CollaborationWeb do
    pipe_through [ :browser, :authenticate_user ]

    delete "/logout", SessionController, :delete
    post "/complete", UserController, :finish
  end

  # public routes
  scope "/", CollaborationWeb do
    pipe_through :browser

    get "/", TopicController, :show

    get "/aborted", SessionController, :aborted
    get "/complete", SessionController, :complete

    get "/login", SessionController, :new
    post "/login", SessionController, :create

    get "/start", UserController, :new
    post "/start", UserController, :create
  end
end
