defmodule Collaboration.Contributions do
  @moduledoc """
  The Contributions context.
  """
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Collaboration.Accounts, only: [condition: 1, time_passed: 1]

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
  end

  defp add_past_bot_to_user_comments(ideas, user) do

    # get bot-to-user response ids and comments
    i_rids = idea_response_ids(user.condition)
    c_rids = comment_response_ids(user.condition)
    comments = get_bot_to_user_comments(user)

    # get the id's of the first two user_ideas
    i_uids = ideas
      |> Enum.filter(fn i -> i.user_id == user.id end)
      |> Enum.map(fn i -> i.id end)
      |> Enum.sort()
      |> Enum.slice(0, Enum.count(i_rids))

    # get the id's of the first three user_comments
    c_uids = ideas
      |> Enum.map(fn i ->
          Enum.filter(i.comments, fn c -> c.user_id == user.id end)
          |> Enum.map(fn c -> c.id end)
        end)
      |> Enum.flat_map(fn c -> c end)
      |> Enum.sort()
      |> Enum.slice(0, Enum.count(c_rids))

    Enum.map ideas, fn i ->
      # potentially add bot-to-user comment on posting idea
      i = case Enum.find_index(i_uids, fn x -> x == i.id end) do
        nil -> i
        index ->
          cid = Enum.at(i_rids, index)
          case Enum.find(comments, fn c -> c.id == cid and
            not future(i.inserted_at) end) do
            nil -> i
            comment ->
              comments = i.comments ++ [comment]
              Map.put(i, :comments, comments)
          end
      end

      # potentially add bot-to-user comment on posting comment
      comments = Enum.map(c_uids, fn id ->
        index = Enum.find_index(c_uids, fn x -> x == id end)
        cid = Enum.at(c_rids, index)

        if Enum.find(i.comments, fn c -> c.id == id end) do
          Enum.find(comments, fn c -> c.id == cid and
          not future(i.inserted_at) end)
        else
          nil
        end
      end)
      |> Enum.reject(fn x -> x == nil end)
      |> Enum.concat(i.comments)
      |> Enum.sort_by(&(&1.inserted_at))

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
    |> Enum.map(fn i -> [
        NaiveDateTime.diff(i.inserted_at, user.inserted_at),
        render_idea(i, user)
      ] end)
  end

  def load_idea(idea_id, user) do
    from(i in Idea, preload: [:ratings, :user ])
    |> Repo.get(idea_id)
    |> View.render_many(IdeaView, "idea.json", user: user)
  end

  # select only ideas/comments that have already been published
  defp get_past(changeset, user) do
    if user.condition > 0 do
      # normal users: show ideas for condition that should be posted by now
      where changeset, [i],
        (field(i, ^condition(user)) < ^time_passed(user) and field(i, ^condition(user)) != 0) or i.user_id == ^user.id
    else
      # admins: show all peer ideas
      where changeset, [i], i.user_id <= 11
    end
  end

  # select only ideas that have not been posted yet
  defp get_future(changeset, user) do
    where changeset, [i], field(i, ^condition(user)) > ^time_passed(user)
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

  def change_idea(idea \\ %Idea{}), do: Idea.changeset(idea, %{})

  def create_idea(params, topic_id, user ) do
    %Idea{}
    |> Idea.changeset(params)
    |> put_change(:topic_id, topic_id)
    |> put_change(:user_id, user.id)
    |> Repo.insert()
  end

  def rate_idea!(rating, idea_id, user_id) do
    rating = case Repo.get_by(Rating, idea_id: idea_id, user_id: user_id) do
      nil -> %Rating{}
      rating -> rating
    end
    |> Rating.changeset(%{ rating: rating, idea_id: idea_id, user_id: user_id })
    |> Repo.insert_or_update!()
    |> Repo.preload([:idea])

    my_rating = rating.rating
    { rating, raters } =
      IdeaView.calc_rating(rating.idea.fake_rating, rating.idea.fake_raters, my_rating)

    %{
      rating: rating,
      raters: raters,
      my_rating: my_rating
    }
  end

  def unrate_idea!(idea_id, user_id) do
    rating = Repo.get_by!(Rating, idea_id: idea_id, user_id: user_id)
    |> Repo.delete!()
    |> Repo.preload([:idea])

    %{
      rating: rating.idea.fake_rating,
      raters: rating.idea.fake_raters,
    }
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
        NaiveDateTime.diff(c.inserted_at, user.inserted_at),
        render_comment(c, user)
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

  def future(date1, date2 \\ NaiveDateTime.utc_now()) do
    remaining(date1, date2) > 0
  end

  def remaining(date1, date2 \\ NaiveDateTime.utc_now()) do
    NaiveDateTime.diff(date1, date2)
  end

  def render_idea(i, user) do
    View.render_to_string( IdeaView, "idea.html", idea: i, user: user )
  end

  def render_comment(c, user) do
    View.render_to_string( CommentView, "comment.html", comment: c, user: user )
  end
end
