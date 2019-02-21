defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Phoenix.View
  alias Collaboration.Repo
  alias Collaboration.Accounts.User
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
    user_query = from u in User, select: u.name

    comments_query = from(c in Comment)
    |> get_where(user)
    |> preload([:likes, user: ^user_query])

    from i in Idea,
      preload: [
        :ratings,
        comments: ^comments_query,
        user: ^user_query
      ]
  end

  # gets list of ideas to a specific topic
  def load_ideas(topic_id, user) do
    idea_query(user)
    |> where(topic_id: ^topic_id)
    |> get_where(user)
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

  def get_user_ideas!(user_id) do
    from(i in Idea,
      select: i.id,
      where: i.user_id == ^user_id,
      order_by: i.inserted_at,
      limit: 2
    )
    |> Repo.all()
  end

  def change_idea(idea \\ %Idea{}), do: Idea.changeset(idea, %{})

  def create_idea(user, topic, attrs) do
    %Idea{}
    |> Idea.changeset(attrs)
    |> put_assoc(:user, user)
    |> put_assoc(:topic, topic)
    |> Repo.insert()
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

  def user_ideas(ideas, user_id) do
    ideas
    |> Enum.filter(fn i -> i.user_id == user_id end)
    |> Enum.map(fn i -> {i.id, i.remaining} end)
  end

  def get_user_comments!(user_id) do
    from(c in Comment,
      select: c.id,
      where: c.user_id == ^user_id,
      order_by: c.inserted_at,
      limit: 3
    )
    |> Repo.all()
  end

  def load_comment(comment_id, user) do
    user_query = from u in User, select: u.name
    from(c in Comment, preload: [:likes, user: ^user_query])
    |> Repo.get(comment_id)
    |> View.render_one(CommentView, "comment.json", user: user)
  end

  def comment_changeset(params \\ %{}) do
    Comment.changeset %Comment{}, params
  end

  def create_comment(params) do
    comment_changeset(params)
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

  # if admin or peer user, show all ideas from admins or peer users or current
  # if experiment user, show all ideas for current condition and user ideas
  defp get_where(changeset, user) do
    if user.condition > 0 do
      condition = String.to_atom "c#{user.condition}"
      where changeset, [i], field(i, ^condition) != 0 or i.user_id == ^user.id
    else
      where changeset, [i], i.user_id <= 11 or i.user_id == ^user.id
    end
  end
end
