defmodule CollaborationWeb.IdeaController do
  use CollaborationWeb, :controller

  # import Collaboration.Contributions
  # alias Collaboration.Contributions.Idea

  # def create(conn, %{"topic_id" => topic_id, "idea" => params}) do
  #   topic = get_topic! topic_id
  #   case create_idea(conn.assigns[:current_user], topic, params) do
  #     {:ok, idea} ->
  #       conn
  #       |> put_flash(:info, "Idea created successfully.")
  #       |> redirect(to: topic_idea_path(conn, :show, topic, idea))
  #     {:error, changeset} ->
  #       render conn, "index.html",
  #         topic: topic,
  #         idea: nil,
  #         idea_changeset: changeset,
  #         edit_idea_changeset: change_idea()
  #   end
  # end

  # def update(conn, %{"topic_id" => topic_id, "id" => id, "idea" => params}) do
  #   idea = get_idea!(id)
  #   case update_idea(idea, params) do
  #     {:ok, idea} ->
  #       conn
  #       |> put_flash(:info, "Idea updated successfully.")
  #       |> redirect(to: topic_idea_path(conn, :show, topic_id, idea))
  #     {:error, changeset} ->
  #       topic = get_topic! topic_id
  #       render conn, "index.html",
  #         topic: topic,
  #         idea: idea,
  #         idea_changeset: change_idea(%Idea{}),
  #         edit_idea_changeset: changeset
  #   end
  # end

  # def delete(conn, %{"topic_id" => topic_id, "id" => id}) do
  #   get_idea!(id) |> delete_idea
  #   conn
  #   |> put_flash(:info, "Idea deleted successfully.")
  #   |> redirect(to: topic_idea_path(conn, :index, topic_id))
  # end
end