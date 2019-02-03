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
  alias Collaboration.Contributions.{ Topic, Idea, Comment, Rating }
  alias CollaborationWeb.{ IdeaView, CommentView }

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


  def idea_query(user) do
    user_query = from u in User, select: u.name

    comments_query = from c in Comment,
      order_by: c.inserted_at,
      where: is_nil(c.recipient_id),        # show bot-to-bot comments
      or_where: c.user_id == ^user.id,      # show own comments
      or_where: c.recipient_id == ^user.id, # show bot-to-user comments (self)
      preload: [:likes, user: ^user_query ]

    from i in Idea,
      order_by: [desc: i.inserted_at],
      preload: [
        :ratings,
        comments: ^comments_query,
        user: ^user_query
      ]
  end

  # gets list of ideas to a specific topic
  def load_ideas(topic_id, user) do
    condition = String.to_atom "c#{user.condition}"

    idea_query(user)
    |> where(topic_id: ^topic_id)
    |> where([i], field(i, ^condition) != 0 or i.user_id == ^user.id)
    |> Repo.all()
    |> View.render_many(IdeaView, "idea.json", user: user)
  end

  # get idea with all details
  def load_idea(idea_id, user) do
    idea_query(user)
    |> Repo.get(idea_id)
    |> View.render_one(IdeaView, "idea.json", user: user)
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

  def render_comment(comment) do
    comment
    |> Repo.preload([:user, :likes])
    |> View.render_one(CommentView, "comment.json", current_user: nil)
  end

  def create_comment(params) do
    %Comment{}
    |> Comment.changeset(params)
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
