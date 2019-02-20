defmodule CollaborationWeb.Router do
  use CollaborationWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session)
  end

  pipeline :protected do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session, protected: true, login: true)
    plug(Coherence.Authentication.Token, source: :params, param: "auth_token")
  end

  pipeline :protected_admin do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Coherence.Authentication.Session, protected: true, login: true)
    plug(Coherence.Authentication.Token, source: :params, param: "auth_token")
    plug CollaborationWeb.Plug.IsAdmin
  end

  scope "/" do
    pipe_through(:browser)
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  # admin routes first
  scope "/", CollaborationWeb do
    pipe_through(:protected_admin)

    # add protected resources below
    resources "/topics", TopicController,
      only: [:index, :new, :create, :edit, :update]
    resources "/users",  UserController, only: [:index, :update]
    post "/feature/:id", TopicController, :feature
    get "/participants", UserController, :participants
  end

  scope "/", CollaborationWeb do
    pipe_through(:protected)

    # add protected resources below
    resources "/comments",  CommentController, only: [:create]
    post "/rate/:idea_id/:rating", IdeaController, :rate
    delete "/rate/:idea_id", IdeaController, :unrate
    post "/like/:comment_id", CommentController, :like
    delete "/like/:comment_id", CommentController, :unlike

    post "/", IdeaController, :create
    post "/complete", UserController, :finish
  end

  scope "/", CollaborationWeb do
    pipe_through(:browser)

    # add public resources below
    get "/", TopicController, :show
    get "/complete", UserController, :complete

    get "/start", UserController, :new
    post "/start", UserController, :create
  end
end
