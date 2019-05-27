defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Collaboration.Accounts, only: [condition: 1, time_passed: 1]

  alias Phoenix.View
  alias Collaboration.Repo
  alias Collaboration.Accounts.User
  alias Collaboration.Contributions.{ Topic, Idea, Comment, Like, Rating }
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

  def count_ideas(user_id) do
    from(i in Idea, where: i.user_id == ^user_id)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Loads all pre- and user-generated ideas with comments
  and those that are bot-generated and already published
  """
  def load_past_ideas(topic_id, user) do
    comments_query = from(c in Comment, preload: [ :likes, :user ])
    |> get_past(user)

    from(i in Idea,
      preload: [ :ratings, :user, comments: ^comments_query ],
      where: [topic_id: ^topic_id]
    )
    |> get_past(user)
    |> Repo.all()
    |> View.render_many(IdeaView, "idea.json", user: user)
    |> Enum.sort_by(&(&1.inserted_at), &>/2) # sort newest first
    |> add_past_bot_to_user_comments(user)
    |> add_past_likes(user)
  end

  defp add_past_bot_to_user_comments(ideas, user) do

    # get bot-to-user response ids and comments
    i_rids = idea_response_ids(user.condition)
    c_rids = comment_response_ids(user.condition)
    bot_comments = get_bot_to_user_comments(user)

    # get the id's of the first two user_ideas
    i_uids = ideas
      |> Enum.filter(fn i -> i.user_id == user.id end)
      |> Enum.map(fn i -> i.id end)
      |> Enum.sort()
      |> Enum.slice(0, Enum.count(i_rids))

    Enum.map ideas, fn i ->
      # potentially add bot-to-user comment on posting idea
      i = case Enum.find_index(i_uids, fn x -> x == i.id end) do
        nil -> i
        index ->
          cid = Enum.at(i_rids, index)
          case Enum.find(bot_comments, fn c -> c.id == cid and
            not future(i.inserted_at) end) do
            nil -> i
            c ->
              inserted_at = NaiveDateTime.add(i.inserted_at, c.delay)
              if remaining(inserted_at) <= 0 do
                c = Map.put(c, :inserted_at, inserted_at)
                Map.put(i, :comments, i.comments ++ [c])
              else
                i
              end
          end
      end

      # get the id's of the first three user_comments
      c_uids = ideas
      |> Enum.map(fn i ->
          Enum.filter(i.comments, fn c -> c.user_id == user.id end)
          |> Enum.map(fn c -> c.id end)
        end)
      |> Enum.flat_map(fn c -> c end)
      |> Enum.sort()
      |> Enum.slice(0, Enum.count(c_rids))

      # potentially add bot-to-user comment on posting comment
      comments = Enum.map(c_uids, fn id ->
        index = Enum.find_index(c_uids, fn x -> x == id end)
        cid = Enum.at(c_rids, index)

        case { Enum.find(i.comments, fn c -> c.id == id end), Enum.find(bot_comments, fn c -> c.id == cid end)} do
          { nil, _ } -> nil
          { _, nil } -> nil
          { c, feedback } ->
            inserted_at = NaiveDateTime.add(c.inserted_at, feedback.delay)
            if remaining(inserted_at) <= 0 do
              Map.put(feedback, :inserted_at, inserted_at)
            else
              nil
            end
        end
      end)
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.concat(i.comments)
      |> Enum.sort_by(&(&1.inserted_at))

      Map.put(i, :comments, comments)
    end
  end

  defp add_past_likes(ideas, user) do
    past_liked_comment_ids = get_delayed_likes(user)
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

  @doc """
  Loads bot-generated ideas that have not yet been published
  """
  def load_future_ideas(topic_id, user) do
    from(i in Idea, preload: [:ratings, :user], where: [topic_id: ^topic_id] )
    |> get_future(user)
    |> Repo.all()
    |> View.render_many(IdeaView, "idea.json", user: user)
    |> Enum.map(fn i -> [ remaining(i.inserted_at), render_idea(i, user) ] end)
  end

  def load_idea(idea_id, user) do
    from(i in Idea, preload: [:ratings, :user ])
    |> Repo.get(idea_id)
    |> View.render_many(IdeaView, "idea.json", user: user)
  end

  def get_inserted_at(idea_id) do
    from(i in Idea, select: i.inserted_at)
    |> Repo.get(idea_id)
  end

  # select only ideas/comments that have already been published
  defp get_past(changeset, user) do
    if user.condition > 0 do
      # normal users: show ideas for condition that should be posted by now
      where changeset, [i],
        field(i, ^condition(user)) <= ^time_passed(user) or i.user_id == ^user.id
    else
      # admins: show all peer and own ideas
      where changeset, [i], i.user_id <= 11
    end
  end

  # select only ideas that have not been posted yet
  defp get_future(changeset, user) do
    if user.condition > 0 do
      where changeset, [i], field(i, ^condition(user)) > ^time_passed(user)
    else
      changeset
    end
  end

  # gets the two oldest user_ids
  def get_user_idea_ids(topic_id, user) do
    from(i in Idea,
      select: {i.id, i.inserted_at},
      where: i.topic_id == ^topic_id and i.user_id == ^user.id,
      order_by: i.inserted_at,
      limit: 2
    )
    |> Repo.all()
    |> Enum.map(fn {id, inserted_at} ->
        { id, NaiveDateTime.diff(inserted_at, NaiveDateTime.utc_now())}
      end)
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

  def comment_changeset() do
    Comment.changeset(%Comment{})
  end

  # gets the two oldest user_ids
  def get_user_comment_ids(user) do
    from(c in Comment,
      select: c.idea_id,
      where: c.user_id == ^user.id,
      order_by: c.inserted_at,
      limit: 3
    ) |> Repo.all()
  end

  # get bot-to-user comments (they do not have an idea_id attached)
  def get_bot_to_user_comments(user) do
    from(c in Comment, preload: [ :likes, :user ], where: is_nil(c.idea_id))
    |> Repo.all()
    |> View.render_many(CommentView, "comment.json", user: user)
  end

  def get_bot_to_bot_comments(user) do
    from(c in Comment, preload: [:likes, :user], where: not is_nil(c.idea_id))
    |> get_future(user)
    |> Repo.all()
    |> View.render_many(CommentView, "comment.json", user: user)
    |> Enum.map(fn c -> [
        c.idea_id,
        render_comment(c, user),
        remaining(c.inserted_at)
      ] end)
  end

  def load_comment(comment, user) when is_number(comment) do
    from(c in Comment, preload: [:likes, :user])
    |> Repo.get(comment)
    |> View.render_one(CommentView, "comment.json", user: user)
  end

  def load_comment(comment, user) when is_map(comment) do
    comment
    |> Repo.preload([:likes, :user ])
    |> View.render_one(CommentView, "comment.json", user: user)
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

  # bot-to-user comment_ids on ideas
  def idea_response_ids(condition) do
    case condition do
      3 -> [24]
      4 -> [26]
      7 -> [28, 29]
      8 -> [33, 34]
      _ -> []
    end
  end

  # bot-to-user comment_ids on comments
  def comment_response_ids(condition) do
    case condition do
      3 -> [25]
      4 -> [27]
      7 -> [30, 31, 32]
      8 -> [35, 36, 37]
      _ -> []
    end
  end

  def get_delayed_likes(user) do
    Application.fetch_env!(:collaboration, :delayed_likes)
    |> Map.get(user.condition)
    |> Enum.map(fn { comment_id, delay } ->
      [ comment_id, remaining(user.inserted_at) + delay ]
    end)
  end

  def get_future_likes(user) do
    get_delayed_likes(user)
    |> Enum.filter(fn [ _comment_id, delay] -> delay > 0 end)
  end

  def get_future_ratings(user) do
    case user.condition do
      6 -> [{ 1, 75, 4 }, { 2, 360, 5 }]
      8 -> [{ 1, 75, 4 }, { 2, 360, 5 }]
      5 -> [{ 6, 75, 4 }, { 7, 360, 5 }]
      7 -> [{ 6, 75, 4 }, { 7, 360, 5 }]
      _ -> []
    end
    |> Enum.map(fn { id, delay, rating } ->
      [ id, max(0, remaining(user.inserted_at) + delay), rating ]
    end)
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
  """
  def remaining(date1, date2 \\ NaiveDateTime.utc_now())
  def remaining(date1, delay) when is_number(delay),
    do: remaining(NaiveDateTime.add(date1, delay))
  def remaining(date1, date2), do: NaiveDateTime.diff(date1, date2)

  def render_idea(i, user) do
    View.render_to_string( IdeaView, "idea.html", idea: i, user: user )
  end

  def render_comment(c, user) do
    View.render_to_string( CommentView, "comment.html", comment: c, user: user )
  end

  defp put_topic(changeset, topic), do: put_assoc(changeset, :topic, topic)

  defp put_user(changeset, user), do: put_assoc(changeset, :user, user)
end
