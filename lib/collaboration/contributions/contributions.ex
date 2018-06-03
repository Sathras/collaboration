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

  def list_topics(admin \\ false) do
    query =
      from(
        t in Topic,
        left_join: i in assoc(t, :ideas),
        group_by: t.id,
        select: %{
          id: t.id,
          title: t.title,
          short_title: t.short_title,
          short_desc: t.short_desc,
          open: t.open,
          featured: t.featured,
          published: t.published,
          idea_count: count(i.id)
        }
      )

    query = if admin, do: query, else: from([t, i] in query, where: t.published)
    Repo.all(query)
  end

  def get_topic_titles!() do
    Repo.all(
      from(
        t in Topic,
        select: %{
          id: t.id,
          short_title: t.short_title,
          short_desc: t.short_desc
        },
        where: t.published and t.featured
      )
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

  # gets list of ideas to a specific topic
  def load_ideas(topic_id, user) do

    # only show pregenerated and own ideas
    valid_authors = list_admin_ids()
    valid_authors = if user && !user.admin,
      do: valid_authors ++ [user.id], else: valid_authors

    ideas = from i in Idea,
      left_join: c in assoc(i, :comments),
      order_by: [desc: i.inserted_at],
      group_by: i.id,
      select: %{
        id: i.id,
        comment_count: count(c.id),
        created: i.inserted_at,
        fake_rating: i.fake_rating,
        fake_raters: i.fake_raters,
        title: i.title,
        user_id: i.user_id
      },
      where: i.topic_id == ^topic_id and i.user_id in ^valid_authors

    ideas = if user do
      from i in ideas,
        left_join: r in Rating,
        on: r.user_id == i.user_id and r.idea_id == i.id,
        group_by: r.rating,
        select_merge: %{ my_rating: r.rating }
    else
      ideas
    end

    View.render_many(Repo.all(ideas), IdeaView, "idea-basic.json", user: user)
  end

  # get idea with all details
  def load_idea(id, user) do
    idea = from i in Idea,
      left_join: u in assoc(i, :user),
      group_by: [i.id, u.name],
      select: %{
        id: i.id,
        author: u.name,
        created: i.inserted_at,
        desc: i.desc,
        fake_rating: i.fake_rating,
        fake_raters: i.fake_raters,
        title: i.title,
        user_id: i.user_id
      }

    # if not authenticated, do not load any comments
    idea = if user do
      from i in idea,
        left_join: r in Rating,
        on: r.user_id == i.user_id and r.idea_id == i.id,
        group_by: [r.rating],
        select_merge: %{ my_rating: r.rating }
    else
      idea
    end
    Repo.get(idea, id)
    |> View.render_one(IdeaView, "idea.json")
  end

  def get_idea!(id), do: Repo.get!(Idea, id)

  def get_idea_details(idea),
    do: Repo.preload(idea, [:user, :comments, :ratings])

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

  def rate_idea!(user, idea_id, rating) do
    case Repo.get_by(Rating, user_id: user.id, idea_id: idea_id) do
      nil -> %Rating{}
      rating -> rating
    end
    |> Rating.changeset(%{rating: rating})
    |> Repo.insert_or_update!()
  end

  def delete_idea(id), do: Repo.delete(get_idea!(id))

  def load_comments(idea_id, user) do
    if user do
      # only load own comments, or feedback (targeted to self)
      from( c in Comment,
        left_join: u in assoc(c, :user),
        left_join: l in assoc(c, :likes), on: [id: ^user.id],
        group_by: [c.id, u.name, l.id],
        select: %{
          id: c.id,
          author: u.name,
          created: c.inserted_at,
          liked: l.id,
          likes: c.fake_likes,
          text: c.text,
          user_id: c.user_id
        },
        order_by: [asc: c.inserted_at],
        where: c.idea_id == ^idea_id and c.user_id == ^user.id,
        or_where: c.idea_id == ^idea_id and c.recipient_id == ^user.id
      )
      |> Repo.all()
      |> View.render_many(CommentView, "comment.json")
    else
      []
    end
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
