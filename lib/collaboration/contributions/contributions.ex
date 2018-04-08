defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset, only: [put_assoc: 3]
  import Ecto.Query, warn: false
  alias Collaboration.Repo
  alias Collaboration.Contributions.Topic
  alias Collaboration.Contributions.Idea

  def list_topics(admin \\ false) do
    query = from t in Topic,
      left_join: i in assoc(t, :ideas),
      group_by: t.id,
      select: %{
        title: t.title, short_title: t.short_title, short_desc: t.short_desc,
        slug: t.slug, open: t.open, featured: t.featured, published: t.published,
        idea_count: count(i.id)
      }
    query = if admin, do: query, else: from [t, i] in query, where: t.published
    Repo.all(query)
  end

  def get_topic!(id), do: Repo.get!(Topic, id)
  def get_topic_via_slug!(slug), do: Repo.get_by(Topic, slug: slug)

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
  def change_topic(topic \\ %Topic{}), do: Topic.changeset(topic, %{})

  def list_ideas, do: Repo.all(Idea)

  def list_ideas(topic_id), do: Repo.all(from i in Idea,
    select: %{id: i.id, title: i.title, created: i.inserted_at},
    where: i.topic_id == ^topic_id
  )

  def get_idea!(id), do: Repo.get!(Idea, id)

  def create_idea(user, topic, attrs \\ %{}) do
    %Idea{}
    |> Idea.changeset(attrs)
    |> put_assoc(:user, user)
    |> put_assoc(:topic, topic)
    |> Repo.insert()
  end

  def update_idea(%Idea{} = idea, attrs) do
    idea
    |> Idea.changeset(attrs)
    |> Repo.update()
  end

  def delete_idea(%Idea{} = idea), do: Repo.delete(idea)
  def change_idea(idea \\ %Idea{}), do:  Idea.changeset(idea, %{})
end
