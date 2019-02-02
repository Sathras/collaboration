defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Collaboration.Coherence.Schemas

  alias Phoenix.View
  alias Collaboration.Repo
  alias Collaboration.Coherence.User
  alias Collaboration.Contributions.Topic
  alias Collaboration.Contributions.Idea
  alias Collaboration.Contributions.Comment
  alias Collaboration.Contributions.Rating
  alias CollaborationWeb.IdeaView
  alias CollaborationWeb.CommentView

  def list_topics do
    from( t in Topic,
      left_join: i in assoc(t, :ideas),
      group_by: t.id,
      select: %{
        id: t.id,
        title: t.title,
        featured: t.featured,
        idea_count: count(i.id)
      }
    )|> Repo.all()
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

  def get_published_topic!, do: Repo.one from(t in Topic, where: t.featured)

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def feature_topic(id) do
    Repo.update_all Topic, set: [featured: false]
    get_topic!(id)
    |> change(featured: true)
    |> Repo.update()
  end

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def delete_topic(%Topic{} = topic), do: Repo.delete(topic)
  def change_topic(topic \\ %Topic{}), do: Topic.changeset(topic, %{})

  # gets list of ideas to a specific topic
  def load_ideas(topic_id, user) do

    # only show own ideas and peer ideas
    valid_authors = get_user_ids(user && user.id, :peers)

    user_query = from u in User
    rating_query = from r in Rating
    comments_query = from c in Comment,
      order_by: c.inserted_at,
      preload: [:likes, :user]

    ideas = from i in Idea,
      order_by: [desc: i.inserted_at],
      preload: [
        user: ^user_query,
        ratings: ^rating_query,
        comments: ^comments_query
      ],
      where: i.topic_id == ^topic_id and i.user_id in ^valid_authors
    View.render_many(Repo.all(ideas), IdeaView, "idea.json", user: user)
  end

  # get idea with all details
  def load_idea(id, user) do
    idea = from i in Idea, preload: [:user, :ratings, comments: [:likes, :user]]
    Repo.get(idea, id) |> View.render_one(IdeaView, "idea.json", user: user)
  end

  def get_idea!(id), do: Repo.get!(Idea, id)

  def get_idea_details(idea),
    do: Repo.preload(idea, [
      :user,
      :ratings,
      comments: (from c in Comment, order_by: c.inserted_at)
    ])

  def render_idea(idea, user) when is_number(idea) do
    View.render_one get_idea!(idea) |> get_idea_details(), IdeaView, "idea.json", user: user
  end

  def render_idea(idea, user) when is_map(idea), do:
    View.render_one get_idea_details(idea), IdeaView, "idea.json", user: user

  def change_idea(idea \\ %Idea{}), do: Idea.changeset(idea, %{})

  def create_idea(user, topic, attrs) do
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

  def get_user_rating!(user, idea),
    do:
      from(
        r in Rating,
        select: r.rating,
        where: r.user_id == ^user.id and r.idea_id == ^idea.id
      )
      |> Repo.one()

  def get_ratings!(idea),
    do:
      from(
        r in Rating,
        select: %{avg: avg(r.rating), count: count(r.rating)},
        where: r.idea_id == ^idea.id
      )
      |> Repo.one!()

  def rate_idea!(user, idea_id, value) do
    case Repo.get_by(Rating, user_id: user.id, idea_id: idea_id) do
      nil ->
        %Rating{}
        |> Rating.changeset(%{rating: value})
        |> put_assoc(:idea, get_idea!(idea_id))
        |> put_assoc(:user, user)
        |> Repo.insert!()
      rating ->
        rating
        |> Rating.changeset(%{rating: value})
        |> Repo.update!()
    end
  end

  def delete_idea(id), do: Repo.delete(get_idea!(id))

  def load_comment(comment_id, user) do
    from(c in Comment, preload: [:user, :likes])
    |> Repo.get(comment_id)
    |> View.render_one(CommentView, "comment.json", user: user)
  end

  def get_comment!(id), do: Repo.get!(Comment, id)
  def get_comment_details(comment), do: Repo.preload(comment, [:user, :likes])

  def render_comment(comment) do
    View.render_one(
      get_comment_details(comment),
      CommentView,
      "comment.json",
      current_user: nil
    )
  end

  def create_comment(author, idea_id, attrs) do
    %Comment{}
    |> Comment.changeset(Map.put(attrs, :public, author.admin))
    |> put_assoc(:user, author)
    |> put_assoc(:idea, get_idea!(idea_id))
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

  def update_comment(id, attrs) when is_number(id) do
    get_comment!(id)
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def update_comment(comment, attrs) when is_map(comment) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment!(id), do: Repo.delete!(get_comment!(id))
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

  def feedback(_idea, _user) do
    # feedbacks = []

  #   %Comment{}
  #   |> Comment.changeset(attrs)
  #   |> put_assoc(:user, author)
  #   |> put_assoc(:recipient, recipient)
  #   |> put_assoc(:idea, idea)
  #   |> Repo.insert()
  end
end
