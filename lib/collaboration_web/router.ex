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
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
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
    get "/", TopicController, :index
    resources "/topics", TopicController
  end

  scope "/", CollaborationWeb do
    pipe_through :protected

    # add protected resources below
    post "/topics/:slug", TopicController, :add_idea
    get "/users", UserController, :index
    put "/users/:id", UserController, :toggle_admin
  end
end
