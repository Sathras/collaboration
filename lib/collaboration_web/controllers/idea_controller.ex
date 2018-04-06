defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller

  alias Collaboration.Contributions
  alias Collaboration.Contributions.Idea

  def index(conn, _params) do
    ideas = Contributions.list_ideas()
    render(conn, "index.html", ideas: ideas)
  end

  def new(conn, _params) do
    changeset = Contributions.change_idea(%Idea{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"idea" => idea_params}) do
    case Contributions.create_idea(idea_params) do
      {:ok, idea} ->
        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: idea_path(conn, :show, idea))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    idea = Contributions.get_idea!(id)
    render(conn, "show.html", idea: idea)
  end

  def edit(conn, %{"id" => id}) do
    idea = Contributions.get_idea!(id)
    changeset = Contributions.change_idea(idea)
    render(conn, "edit.html", idea: idea, changeset: changeset)
  end

  def update(conn, %{"id" => id, "idea" => idea_params}) do
    idea = Contributions.get_idea!(id)

    case Contributions.update_idea(idea, idea_params) do
      {:ok, idea} ->
        conn
        |> put_flash(:info, "Idea updated successfully.")
        |> redirect(to: idea_path(conn, :show, idea))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", idea: idea, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    idea = Contributions.get_idea!(id)
    {:ok, _idea} = Contributions.delete_idea(idea)

    conn
    |> put_flash(:info, "Idea deleted successfully.")
    |> redirect(to: idea_path(conn, :index))
  end
end
