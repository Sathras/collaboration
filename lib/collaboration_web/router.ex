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

    resources "/comments",  CommentController, only: [:create]
    post "/rate/:idea_id/:rating", IdeaController, :rate
    delete "/rate/:idea_id", IdeaController, :unrate
    post "/like/:comment_id", CommentController, :like
    delete "/like/:comment_id", CommentController, :unlike

    delete "/logout", SessionController, :delete

    post "/", IdeaController, :create
    post "/complete", UserController, :finish
  end

  # public routes
  scope "/", CollaborationWeb do
    pipe_through :browser

    get "/", TopicController, :show
    get "/complete", UserController, :complete

    get "/login", SessionController, :new
    post "/login", SessionController, :create

    get "/start", UserController, :new
    post "/start", UserController, :create
  end
end
