defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Phoenix.View
  alias Collaboration.Repo
  alias Collaboration.Contributions.Topic
  alias Collaboration.Contributions.Idea
  alias Collaboration.Contributions.Comment
  alias Collaboration.Contributions.Rating
  alias CollaborationWeb.CommentView
  alias CollaborationWeb.IdeaView

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

  def get_topic_titles!() do
    Repo.all(from t in Topic,
      select: %{id: t.id, short_title: t.short_title, short_desc: t.short_desc},
      where: t.published and t.featured
    )
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

  def list_ideas(topic_id, last_seen_id, user_id) do
    ideas = Repo.all(
      from i in Idea,
      preload: [:user, :comments, :ratings],
      where: i.topic_id == ^topic_id and i.id > ^last_seen_id
    )
    View.render_many ideas, IdeaView, "idea.json", user_id: user_id
  end

  def get_idea!(id), do: Repo.get!(Idea, id)
  def get_idea_details(idea), do: Repo.preload idea, [:user, :comments, :ratings]

  def render_idea(idea, user_id) when is_number(idea) do
    View.render_one get_idea!(idea) |> get_idea_details(),
      IdeaView, "idea.json", user_id: user_id
  end

  def render_idea(idea, user_id) when is_map(idea) do
    View.render_one get_idea_details(idea),
      IdeaView, "idea.json", user_id: user_id
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

  def list_comments(idea_id, last_seen_id, user_id \\ nil) do
    query = from c in Comment,
      order_by: [asc: c.id],
      preload: [:user, :likes],
      where: c.id > ^last_seen_id and c.idea_id == ^idea_id and is_nil(c.recipient_id)

    query = if is_binary(user_id) do
      from c in query,
        or_where: c.id > ^last_seen_id and c.idea_id == ^idea_id and c.recipient_id == ^user_id
    else
      query
    end

    View.render_many(Repo.all(query), CommentView, "comment.json", current_user: user_id)
  end

  def get_comment!(id), do: Repo.get!(Comment, id)
  def get_comment_details(comment), do: Repo.preload comment, [:user, :likes]

  def render_comment(comment) do
    View.render_one(
      get_comment_details(comment), CommentView, "comment.json",
      current_user: nil
    )
  end

  def create_comment(author, idea, attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> put_assoc(:user, author)
    |> put_assoc(:idea, idea)
    |> Repo.insert()
  end

  def create_comment(author, recipient, idea, attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> put_assoc(:user, author)
    |> put_assoc(:recipient, recipient)
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
    |> Repo.update()
  end

  def unlike_comment(user, id) do
    comment = Repo.get(Comment, id) |> Repo.preload(:likes)
    comment
    |> change()
    |> put_assoc(:likes, List.delete(comment.likes, user))
    |> Repo.update()
  end
end
