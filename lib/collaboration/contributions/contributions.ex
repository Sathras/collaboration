defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Collaboration.Repo
  alias Collaboration.Contributions.Topic
  alias Collaboration.Contributions.Idea
  alias Collaboration.Contributions.Comment
  alias Collaboration.Contributions.Rating

  def list_topics(admin \\ false) do
    query = from t in Topic,
      left_join: i in assoc(t, :ideas),
      group_by: t.id,
      select: %{
        id: t.id, title: t.title, short_title: t.short_title,
        short_desc: t.short_desc, open: t.open, featured: t.featured,
        published: t.published, idea_count: count(i.id)
      }
    query = if admin, do: query, else: from [t, i] in query, where: t.published
    Repo.all(query)
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

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
    left_join: c in assoc(i, :comments),
    left_join: r in assoc(i, :ratings),
    group_by: i.id,
    select: %{
      id: i.id,
      title: i.title,
      created: i.inserted_at,
      comment_count: count(c.id),
      real_rating: avg(r.rating),
      real_raters: count(r.id),
      fake_rating: i.fake_rating,
      fake_raters: i.fake_raters
    },
    where: i.topic_id == ^topic_id
  )

  def get_idea!(id), do: Repo.get!(Idea, id)
  def get_idea!(id, :preload_comments) do
    from(i in Idea, preload: [comments: [:user, :likes]]) |> Repo.get!(id)
  end

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

  def get_user_rating!(user, idea), do:
    from( r in Rating,
      select: r.rating,
      where: r.user_id == ^user.id and r.idea_id == ^idea.id
    ) |> Repo.one()

  def get_ratings!(idea), do:
    from( r in Rating,
      select: %{ avg: avg(r.rating), count: count(r.rating)},
      where: r.idea_id == ^idea.id
    ) |> Repo.one!()

  def rate_idea!(user, idea, params) do
    case Repo.get_by(Rating, [user_id: user.id, idea_id: idea.id]) do
      nil ->
        %Rating{}  # rating not found, we build one
        |> Rating.changeset(params)
        |> put_assoc(:user, user)
        |> put_assoc(:idea, idea)
        |> Repo.insert!()
      rating  ->
        rating     # rating exists, let's use it
        |> Rating.changeset(params)
        |> Repo.update!()
    end
  end

  def delete_idea(%Idea{} = idea), do: Repo.delete(idea)
  def change_idea(idea \\ %Idea{}), do:  Idea.changeset(idea, %{})

  def list_comments, do: Repo.all(Comment)

  def get_comment!(id), do: Repo.get!(Comment, id)

  def create_comment(user, idea, attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> put_assoc(:user, user)
    |> put_assoc(:idea, idea)
    |> Repo.insert()
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comment{} = comment), do: Repo.delete(comment)
  def change_comment(%Comment{} = comment), do: Comment.changeset(comment, %{})

  def like_comment(user, id) do
    Repo.get(Comment, id)
    |> Repo.preload(:likes)
    |> change()
    |> put_assoc(:likes, [user])
    |> Repo.update!()
  end

  def unlike_comment(user, id) do
    comment = Repo.get(Comment, id) |> Repo.preload(:likes)
    comment
    |> change()
    |> put_assoc(:likes, List.delete(comment.likes, user))
    |> Repo.update!()
  end
end
