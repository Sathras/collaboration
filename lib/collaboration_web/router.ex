defmodule CollaborationWeb.Router do
  use CollaborationWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :add_topic
    plug CollaborationWeb.Auth
  end

  pipeline :protected do
    plug :add_topic
    plug :authenticate_user
  end

  pipeline :admin do
    plug :authenticate_admin
  end

  # admin routes
  scope "/", CollaborationWeb do
    pipe_through [ :browser, :protected, :admin ]

    resources "/topics", TopicController,
      only: [:index, :new, :create, :edit, :update]
    resources "/users",  UserController, only: [:index, :update]
    post "/feature/:id", TopicController, :feature
    get "/participants", UserController, :participants
    get "/admin", DownloadController, :index
  end

  # protected routes
  scope "/", CollaborationWeb do
    pipe_through [ :browser, :add_topic, :protected ]

    get "/", TopicController, :show
    post "/", IdeaController, :create
    resources "/comment", CommentController, only: [:index, :create]
    post "/rate", IdeaController, :rate
    delete "/rate/:idea_id", IdeaController, :unrate

    put "/comments/:id/toggle_like", CommentController, :toggle_like

    delete "/logout", SessionController, :delete
    post "/complete", UserController, :finish
  end

  # public routes
  scope "/", CollaborationWeb do
    pipe_through :browser

    get "/abort", SessionController, :abort
    get "/complete", SessionController, :complete

    get "/login", SessionController, :new
    post "/login", SessionController, :create

    get "/start", UserController, :new
    post "/start", UserController, :create
  end
end
