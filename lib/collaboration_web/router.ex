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
    plug(CollaborationWeb.Plug.LoadTopics)
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
    plug(CollaborationWeb.Plug.LoadTopics)
  end

  scope "/" do
    pipe_through(:browser)
    coherence_routes()
  end

  scope "/" do
    pipe_through(:protected)
    coherence_routes(:protected)
  end

  # admin routes first
  scope "/", CollaborationWeb do
    pipe_through(:protected_admin)

    # add protected resources below
    resources "/topics", TopicController, only: [:new, :create, :edit, :update] do
      resources "/ideas", IdeaController, only: [:delete]
    end
    resources "/users",  UserController, only: [:index, :update]
    get "/participants", UserController, :participants
  end

  scope "/", CollaborationWeb do
    pipe_through(:protected)

    # add protected resources below
    resources "/topics", TopicController, only: [:index, :show] do
      resources "/ideas", IdeaController, only: [:create]
    end
    post "/complete", UserController, :finish
  end

  scope "/", CollaborationWeb do
    pipe_through(:browser)

    # add public resources below
    get "/", TopicController, :home
    get "/complete", UserController, :complete

    get "/start", UserController, :start
    post "/start", UserController, :create
  end
end
