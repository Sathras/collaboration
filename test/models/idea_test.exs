defmodule Collaboration.IdeaTest do
  use Collaboration.ModelCase

  alias Collaboration.Idea

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Idea.changeset(%Idea{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Idea.changeset(%Idea{}, @invalid_attrs)
    refute changeset.valid?
  end
end
