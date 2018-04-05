defmodule Collaboration.ContributionsTest do
  use Collaboration.DataCase

  alias Collaboration.Contributions

  describe "topics" do
    alias Collaboration.Contributions.Topic

    @valid_attrs %{desc: "some desc", open: true, published: true, short_desc: "some short_desc", short_title: "some short_title", title: "some title"}
    @update_attrs %{desc: "some updated desc", open: false, published: false, short_desc: "some updated short_desc", short_title: "some updated short_title", title: "some updated title"}
    @invalid_attrs %{desc: nil, open: nil, published: nil, short_desc: nil, short_title: nil, title: nil}

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
      assert {:error, %Ecto.Changeset{}} = Contributions.create_topic(@invalid_attrs)
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
      assert {:error, %Ecto.Changeset{}} = Contributions.update_topic(topic, @invalid_attrs)
      assert topic == Contributions.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Contributions.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> Contributions.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Contributions.change_topic(topic)
    end
  end
end
