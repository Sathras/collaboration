defmodule Collaboration.ContributionsTest do
  use Collaboration.DataCase

  alias Collaboration.Contributions

  describe "topics" do
    alias Collaboration.Contributions.Topic

    @valid_attrs %{
      desc: "some desc",
      open: true,
      published: true,
      short_desc: "some short_desc",
      short_title: "some short_title",
      title: "some title"
    }
    @update_attrs %{
      desc: "some updated desc",
      open: false,
      published: false,
      short_desc: "some updated short_desc",
      short_title: "some updated short_title",
      title: "some updated title"
    }
    @invalid_attrs %{
      desc: nil,
      open: nil,
      published: nil,
      short_desc: nil,
      short_title: nil,
      title: nil
    }

    def topic_fixture(attrs \\ %{}) do
      {:ok, topic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contributions.create_topic()

      topic
    end

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      assert Contributions.list_topics() == [topic]
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      assert Contributions.get_topic!(topic.id) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      assert {:ok, %Topic{} = topic} = Contributions.create_topic(@valid_attrs)
      assert topic.desc == "some desc"
      assert topic.open == true
      assert topic.published == true
      assert topic.short_desc == "some short_desc"
      assert topic.short_title == "some short_title"
      assert topic.title == "some title"
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Contributions.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      assert {:ok, topic} = Contributions.update_topic(topic, @update_attrs)
      assert %Topic{} = topic
      assert topic.desc == "some updated desc"
      assert topic.open == false
      assert topic.published == false
      assert topic.short_desc == "some updated short_desc"
      assert topic.short_title == "some updated short_title"
      assert topic.title == "some updated title"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Contributions.update_topic(topic, @invalid_attrs)

      assert topic == Contributions.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Contributions.delete_topic(topic)

      assert_raise Ecto.NoResultsError, fn ->
        Contributions.get_topic!(topic.id)
      end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Contributions.change_topic(topic)
    end
  end

  describe "ideas" do
    alias Collaboration.Contributions.Idea

    @valid_attrs %{desc: "some desc", title: "some title"}
    @update_attrs %{desc: "some updated desc", title: "some updated title"}
    @invalid_attrs %{desc: nil, title: nil}

    def idea_fixture(attrs \\ %{}) do
      {:ok, idea} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contributions.create_idea()

      idea
    end

    test "list_ideas/0 returns all ideas" do
      idea = idea_fixture()
      assert Contributions.list_ideas() == [idea]
    end

    test "get_idea!/1 returns the idea with given id" do
      idea = idea_fixture()
      assert Contributions.get_idea!(idea.id) == idea
    end

    test "create_idea/1 with valid data creates a idea" do
      assert {:ok, %Idea{} = idea} = Contributions.create_idea(@valid_attrs)
      assert idea.desc == "some desc"
      assert idea.title == "some title"
    end

    test "create_idea/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Contributions.create_idea(@invalid_attrs)
    end

    test "update_idea/2 with valid data updates the idea" do
      idea = idea_fixture()
      assert {:ok, idea} = Contributions.update_idea(idea, @update_attrs)
      assert %Idea{} = idea
      assert idea.desc == "some updated desc"
      assert idea.title == "some updated title"
    end

    test "update_idea/2 with invalid data returns error changeset" do
      idea = idea_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Contributions.update_idea(idea, @invalid_attrs)

      assert idea == Contributions.get_idea!(idea.id)
    end

    test "delete_idea/1 deletes the idea" do
      idea = idea_fixture()
      assert {:ok, %Idea{}} = Contributions.delete_idea(idea)

      assert_raise Ecto.NoResultsError, fn ->
        Contributions.get_idea!(idea.id)
      end
    end

    test "change_idea/1 returns a idea changeset" do
      idea = idea_fixture()
      assert %Ecto.Changeset{} = Contributions.change_idea(idea)
    end
  end

  describe "comments" do
    alias Collaboration.Contributions.Comment

    @valid_attrs %{text: "some text"}
    @update_attrs %{text: "some updated text"}
    @invalid_attrs %{text: nil}

    def comment_fixture(attrs \\ %{}) do
      {:ok, comment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contributions.create_comment()

      comment
    end

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Contributions.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Contributions.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      assert {:ok, %Comment{} = comment} =
               Contributions.create_comment(@valid_attrs)

      assert comment.text == "some text"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Contributions.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()

      assert {:ok, comment} =
               Contributions.update_comment(comment, @update_attrs)

      assert %Comment{} = comment
      assert comment.text == "some updated text"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Contributions.update_comment(comment, @invalid_attrs)

      assert comment == Contributions.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Contributions.delete_comment(comment)

      assert_raise Ecto.NoResultsError, fn ->
        Contributions.get_comment!(comment.id)
      end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Contributions.change_comment(comment)
    end
  end
end
