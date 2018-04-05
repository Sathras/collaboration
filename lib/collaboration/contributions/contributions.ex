defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """

  import Ecto.Query, warn: false
  alias Collaboration.Repo

  alias Collaboration.Contributions.Topic

  def list_topics, do: Repo.all(Topic)
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

  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  def change_topic(%Topic{} = topic) do
    Topic.changeset(topic, %{})
  end
end
