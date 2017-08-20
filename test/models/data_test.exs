defmodule Collaboration.DataTest do
  use Collaboration.ModelCase

  alias Collaboration.Data

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Data.changeset(%Data{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Data.changeset(%Data{}, @invalid_attrs)
    refute changeset.valid?
  end
end
