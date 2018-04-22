defmodule CollaborationWeb.Router do
  use CollaborationWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
    plug CollaborationWeb.Plug.LoadTopics
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true, login: true
    plug Coherence.Authentication.Token, source: :params, param: "auth_token"
    plug CollaborationWeb.Plug.LoadTopics
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", CollaborationWeb do
    pipe_through :browser

    # add public resources below
    get "/", PageController, :index
    resources "/topics", TopicController, only: [:index, :show]
  end

  scope "/", CollaborationWeb do
    pipe_through :protected

    # add protected resources below
    resources "/topics", TopicController, except: [:index, :show]

    get "/users",                     AdminController, :users
    put "/users/:id/toggle_admin",    AdminController, :toggle_admin
    put "/users/:id/toggle_feedback", AdminController, :toggle_feedback
  end
end
