defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Collaboration.Accounts, only: [condition: 1]

  alias Phoenix.View
  alias Collaboration.Repo
  alias Collaboration.Accounts.User
  alias Collaboration.Contributions.{ Topic, Idea, Comment, Like, Rating }
  alias CollaborationWeb.{ IdeaView, CommentView }

  @minTime Application.fetch_env!(:collaboration, :minTime)

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

  def get_published_topic, do: Repo.get_by(Topic, featured: true)

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

  def change_topic(%Topic{} = topic), do: Topic.changeset(topic, %{})

  # IDEAS

  @doc """
  Loads all pre- and user-generated ideas with comments and add relevant bot-generated comments
  """
  def load_ideas(topic, user) do

    # load delayed likes and set reload_in accordingly
    bot_likes = get_bot_likes(user)
    bot_ratings = get_bot_ratings(user)

    next_bot_like_in =
      bot_likes
        |> Enum.map(fn x -> List.last(x) end)
        |> Enum.filter(fn x -> x > 0 end)
        |> List.first()
    next_bot_like_in =
      case next_bot_like_in do
        nil -> 0
        time -> time
      end

    # determine if a rating or like is about to happen and decrease timer if so
    reload_in = min(
      max(0, remaining(user.inserted_at, @minTime)),
      next_bot_like_in
    )

    {_idea_id, delay, _rating } = List.first(bot_ratings)
    reload_in = if remaining(user.inserted_at, delay) > 0,
      do: min(reload_in, remaining(user.inserted_at, delay)),
      else: reload_in

    # load normal ideas with associated comments
    comments_query = where_condition_matches(from(c in Comment, preload: [ :likes, :user ]), user)

    ideas =
      from(i in Idea,
        preload: [ :ratings, :user, comments: ^comments_query ],
        where: [topic_id: ^topic.id]
      )
      |> where_condition_matches(user)
      |> Repo.all()
      |> View.render_many(IdeaView, "idea.json",
          user: user,
          bot_ratings: bot_ratings,
          responses: get_responses(user)
        )
      |> Enum.sort_by(&(&1.inserted_at), &>/2) # sort newest first
      |> add_past_likes(bot_likes)

    reload_in2 =
      ideas
      |> Enum.map(fn i -> i.reload_in end)
      |> Enum.min()

    reload_in = min(reload_in, reload_in2)

    {reload_in, ideas}
  end

  defp add_past_likes(ideas, bot_likes) do
    past_liked_comment_ids =
      bot_likes
      |> Enum.filter(fn [ _comment_id, delay] -> delay <= 0 end)
      |> Enum.map(fn [ comment_id, _delay ] -> comment_id end)

    Enum.map ideas, fn i ->
      comments = Enum.map(i.comments, fn c ->
        if Enum.member?(past_liked_comment_ids, c.id),
          do: Map.put(c, :likes, c.likes + 1),
          else: c
      end)
      Map.put(i, :comments, comments)
    end
  end

  defp where_condition_matches(changeset, user) do
    if user.condition > 0 do
      # normal users: show elements that are present in condition of user or user elements
      where changeset, [i],
        field(i, ^condition(user)) != 0 or i.user_id == ^user.id
    else
      # admins: show all peer and own ideas
      where changeset, [i], i.user_id <= 11
    end
  end

  def create_idea(%User{} = user, %Topic{} = topic, attrs \\ %{}) do
    %Idea{}
    |> Idea.changeset(attrs)
    |> put_topic(topic)
    |> put_user(user)
    |> Repo.insert()
  end

  def change_idea(%Idea{} = idea), do: Idea.changeset(idea, %{})

  def change_rating(%Rating{} = rating), do: Rating.changeset(rating, %{})

  def rate_idea(%User{} = user, attrs) do
    case Repo.get_by(Rating, idea_id: attrs["idea_id"], user_id: user.id) do
      nil ->
        %Rating{}
        |> Rating.changeset(attrs)
        |> put_user(user)
      rating ->
        Rating.changeset(rating, attrs)
    end
    |> Repo.insert_or_update()
  end

  def unrate_idea(%User{} = user, idea_id) do
    Rating
    |> Repo.get_by!(idea_id: idea_id, user_id: user.id)
    |> Repo.delete()
  end

  def comment_changeset, do: Comment.changeset(%Comment{})

  # get relevant bot-to-user comments
  def get_responses(user) do
    # find all bot-to-user comments (they do not have an idea_id attached)
    comments = Repo.all(from(c in Comment, preload: [ :likes, :user ], where: is_nil(c.idea_id)))

    # select the ones that match the list of comment responses in the settings file
    idea_responses =
      user
      |> idea_response_ids()
      |> Enum.map(fn id -> Enum.find(comments, fn c -> c.id == id end) end)

    comment_responses =
      user
      |> comment_response_ids()
      |> Enum.map(fn id -> Enum.find(comments, fn c -> c.id == id end) end)

    { idea_responses, comment_responses }
  end

  # bot-to-user comment_ids on ideas
  defp idea_response_ids(user) do
    :collaboration
    |> Application.fetch_env!(:idea_response_ids)
    |> Map.get(user.condition, [])
  end

  # bot-to-user comment_ids on comments
  defp comment_response_ids(user) do
    :collaboration
    |> Application.fetch_env!(:comment_response_ids)
    |> Map.get(user.condition, [])
  end

  def create_comment(%User{} = user, attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  def change_comment(%Comment{} = comment), do: Comment.changeset(comment, %{})

  def toggle_like_comment(comment_id, user_id) do
    case Repo.get_by(Like, [comment_id: comment_id, user_id: user_id]) do
      nil ->
        %Like{}
        |> Like.changeset(%{comment_id: comment_id, user_id: user_id})
        |> Repo.insert(on_conflict: :nothing)
      like ->
        Repo.delete(like)
    end
  end

  def get_bot_likes(user) do
    Application.fetch_env!(:collaboration, :delayed_likes)
    |> Map.get(user.condition, [])
    |> Enum.map(fn { comment_id, delay } -> [comment_id, remaining(user.inserted_at) + delay] end)
  end

  def get_bot_ratings(user) do
    Map.get(Application.fetch_env!(:collaboration, :future_ratings), user.condition, [])
  end

  @spec future(NaiveDateTime.t(), NaiveDateTime.t()) :: boolean()
  def future(date1, date2 \\ NaiveDateTime.utc_now()) do
    remaining(date1, date2) > 0
  end

  @doc """
  remaining(date1, delay)
    adds delay to a NaiveDatetime and then compares to current time
  remaining(date1, date2)
    compares two NaiveDatetimes (date2 is by default now)

  Example: remaining(user.inserted_at, 100), experiment was started 60 seconds ago.
  Result: 40 (x-60+100 - x)
  """
  def remaining(date, date2 \\ NaiveDateTime.utc_now())
  def remaining(date, delay) when is_number(delay), do: remaining(NaiveDateTime.add(date, delay))
  def remaining(date, date2), do: NaiveDateTime.diff(date, date2)

  def render_idea(i, user) do
    View.render_to_string( IdeaView, "idea.html", idea: i, user: user )
  end

  def render_comment(c, user) do
    View.render_to_string( CommentView, "comment.html", comment: c, user: user )
  end

  defp put_topic(changeset, topic), do: put_assoc(changeset, :topic, topic)

  defp put_user(changeset, user), do: put_assoc(changeset, :user, user)
end
