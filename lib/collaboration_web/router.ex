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
    resources "/topics", TopicController, only: [:index, :edit, :new, :create, :update, :delete]
    get "/topics/:slug", TopicController, :show
    get "/topics/:slug/:idea_id", TopicController, :show
  end

  scope "/", CollaborationWeb do
    pipe_through :protected

    # add protected resources below
    post    "/topics/:slug",          TopicController, :add_idea
    put     "/topics/:slug/:idea_id", TopicController, :update_idea
    delete  "/topics/:slug/:idea_id", TopicController, :delete_idea
    get     "/users",                 UserController, :index
    put     "/users/:id",             UserController, :toggle_admin
  end
end
