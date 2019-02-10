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

  def change_topic(topic \\ %Topic{}), do: Topic.changeset(topic, %{})

  def idea_query(user) do

    condition = String.to_atom "c#{user.condition}"
    user_query = from u in User, select: u.name
    time = NaiveDateTime.diff(NaiveDateTime.utc_now, user.inserted_at)

    comments_query = from c in Comment,
      where: field(c, ^condition) != 0 or c.user_id == ^user.id,
      preload: [:likes, user: ^user_query ]

    from i in Idea,
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
    |> Enum.sort_by(fn(i) -> i.created end, &>=/2)
  end

  # get idea with all details
  def load_idea(idea_id, user) do
    idea_query(user)
    |> Repo.get(idea_id)
    |> View.render_one(IdeaView, "idea.json", user: user)
  end

  def get_idea!(id), do: Repo.get!(Idea, id)

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

  def rate_idea!(rating, idea_id, user_id) do
    case Repo.get_by(Rating, idea_id: idea_id, user_id: user_id) do
      nil -> %Rating{}
      rating -> rating
    end
    |> Rating.changeset(%{ rating: rating, idea_id: idea_id, user_id: user_id })
    |> Repo.insert_or_update!()
  end

  def unrate_idea!(idea_id, user_id) do
    case Repo.get_by(Rating, idea_id: idea_id, user_id: user_id) do
      nil -> :error
      rating ->
        Repo.delete!(rating)
        :ok
    end
  end

  def load_comment(comment_id, user) do
    user_query = from u in User, select: u.name
    from(c in Comment, preload: [:likes, user: ^user_query])
    |> Repo.get(comment_id)
    |> View.render_one(CommentView, "comment.json", user: user)
  end

  def create_comment(params) do
    %Comment{}
    |> Comment.changeset(params)
    |> Repo.insert()
  end

  def update_comment(id, attrs) when is_number(id) do
    %Comment{}
    |> Repo.one(id)
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

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
