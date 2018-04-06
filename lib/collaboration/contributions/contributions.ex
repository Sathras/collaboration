defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Query, warn: false
  alias Collaboration.Repo
  alias Collaboration.Contributions.Topic
  alias Collaboration.Contributions.Idea

  def list_topics, do: Repo.all(Topic)
  def get_topic!(id), do: Repo.get!(Topic, id)
  def get_topic_via_slug!(slug), do: Repo.get_by(Topic, slug: slug)
  def get_menu_links!(), do: Repo.all from t in Topic,
    select: %{slug: t.slug, short_title: t.short_title}, where: t.featured

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def delete_topic(%Topic{} = topic), do: Repo.delete(topic)
  def change_topic(%Topic{} = topic), do: Topic.changeset(topic, %{})
  def list_ideas, do: Repo.all(Idea)
  def get_idea!(id), do: Repo.get!(Idea, id)

  def create_idea(attrs \\ %{}) do
    %Idea{}
    |> Idea.changeset(attrs)
    |> Repo.insert()
  end

  def update_idea(%Idea{} = idea, attrs) do
    idea
    |> Idea.changeset(attrs)
    |> Repo.update()
  end

  def delete_idea(%Idea{} = idea) do
    Repo.delete(idea)
  end

  def change_idea(%Idea{} = idea) do
    Idea.changeset(idea, %{})
  end
end