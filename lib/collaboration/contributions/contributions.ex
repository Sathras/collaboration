defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Collaboration.Accounts, only: [user_query: 0]

  alias Phoenix.View
  alias Collaboration.Repo
  alias Collaboration.Contributions.{ Topic, Idea, Comment, Rating }
  alias CollaborationWeb.{ IdeaView, CommentView }

  # TOPICS

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

  def get_featured_topic_id!() do
    Repo.one from(t in Topic, select: t.id, where: t.featured)
  end

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

  # IDEAS

  def idea_query(user) do
    comments_query = comment_query() |> get_past(user)

    from i in Idea,
      preload: [ :ratings, comments: ^comments_query, user: ^user_query() ]
  end

  def load_past_ideas(topic_id, user) do
    idea_query(user)
    |> where(topic_id: ^topic_id)
    |> get_past(user)
    |> Repo.all()
    |> View.render_many(IdeaView, "idea.json", user: user)
    |> Enum.sort_by(fn(i) -> i.inserted_at end, &>=/2)
  end

  def load_future_ideas(topic_id, user) do
    idea_query(user)
    |> where(topic_id: ^topic_id)
    |> get_future(user)
    |> Repo.all()
    |> View.render_many(IdeaView, "idea.json", user: user)
    |> Enum.sort_by(fn(i) -> i.inserted_at end, &>=/2)
  end


  # select only ideas/comments that have already been published
  defp get_past(changeset, user) do
    time = NaiveDateTime.diff NaiveDateTime.utc_now(), user.inserted_at

    if user.condition > 0 do
      # normal users: show ideas for condition that should be posted by now
      condition = String.to_atom "c#{user.condition}"
      where changeset, [i],
        (field(i, ^condition) < ^time and field(i, ^condition) != 0) or i.user_id == ^user.id
    else
      # admins: show all peer ideas
      where changeset, [i], i.user_id <= 11
    end
  end

  # select only ideas that have not been posted yet
  defp get_future(changeset, user) do
    time = NaiveDateTime.diff NaiveDateTime.utc_now(), user.inserted_at
    condition = String.to_atom "c#{user.condition}"
    where changeset, [i], field(i, ^condition) > ^time
  end

  def get_idea_ids!(topic_id, user) do
    condition = String.to_atom "c#{user.condition}"
    from(i in Idea,
      select: {i.id, i.user_id},
      where: i.topic_id == ^topic_id,
      where: field(i, ^condition) != 0 or i.user_id == ^user.id,
      order_by: i.inserted_at
    )
    |> Repo.all()
  end

  def change_idea(idea \\ %Idea{}), do: Idea.changeset(idea, %{})

  def create_idea(params, topic_id, user ) do
    %Idea{}
    |> Idea.changeset(params)
    |> put_change(:topic_id, topic_id)
    |> put_change(:user_id, user.id)
    |> Repo.insert!()
    |> Repo.preload([user: user_query()])
    |> Map.put(:ratings, [])
    |> Map.put(:comments, [])
    |> View.render_one(IdeaView, "idea.json", user: user)
  end

  def rate_idea(rating, idea_id, user_id) do
    case Repo.get_by(Rating, idea_id: idea_id, user_id: user_id) do
      nil -> %Rating{}
      rating -> rating
    end
    |> Rating.changeset(%{ rating: rating, idea_id: idea_id, user_id: user_id })
    |> Repo.insert_or_update()
  end

  def unrate_idea(idea_id, user_id) do
    Rating
    |> Repo.get_by!(idea_id: idea_id, user_id: user_id)
    |> Repo.delete()
  end

  def user_ideas(ideas, user_id) do
    ideas
    |> Enum.filter(fn i -> i.user_id == user_id end)
    |> Enum.map(fn i -> {i.id, i.remaining} end)
  end

  def comment_query() do
    from c in Comment, preload: [:likes, user: ^user_query()]
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

  def load_future_comments(idea_ids, user) do
    comment_query()
    |> where([c], c.idea_id in ^idea_ids)
    |> get_future(user)
    |> Repo.all()
    |> View.render_many(CommentView, "comment.json", user: user)
    |> Enum.sort_by(fn(i) -> i.inserted_at end, &>=/2)
  end

  def load_comment(comment, user) when is_number(comment) do
    from(c in Comment, preload: [:likes, user: ^user_query()])
    |> Repo.get(comment)
    |> View.render_one(CommentView, "comment.json", user: user)
  end

  def load_comment(comment, user) when is_map(comment) do
    comment
    |> Repo.preload([:likes, user: user_query()])
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

  def like_comment(user, id, like?) do
    comment = Repo.get(Comment, id)
    |> Repo.preload(:likes)
    |> change()

    case like? do
      true ->
        comment
        |> put_assoc(:likes, comment.data.likes ++ [user])
        |> Repo.update()
      false ->
        comment
        |> put_assoc(:likes, List.delete(comment.data.likes, user))
        |> Repo.update()
    end
  end
end
