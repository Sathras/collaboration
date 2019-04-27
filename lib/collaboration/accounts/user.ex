defmodule Collaboration.Accounts.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Collaboration.Accounts.Credential
  alias Collaboration.Contributions.{ Idea, Comment, Rating }

  # verify new experiment users via passcode
  # @passcode_hash Application.fetch_env!(:collaboration, :passcode)
  #   |> Pbkdf2.hash_pwd_salt()

  schema "users" do

    field :name, :string
    field :completed, :boolean
    field :condition, :integer, default: 0
    # field :passcode, :string, virtual: true
    field :uid, :integer
    timestamps()

    has_one :credential, Credential

    has_many :comments, Comment, on_delete: :delete_all
    has_many :ideas, Idea, on_delete: :delete_all
    has_many :ratings, Rating, on_delete: :delete_all

    many_to_many :likes, Comment, join_through: "likes", on_delete: :delete_all
  end

  def changeset(user), do: cast(user, %{}, [:name, :uid])

  def admin_changeset(user, params) do
    user
    |> cast(params, [:name])
    |> validate_required([:name])
    |> put_change(:condition, 0)
    |> put_credential(params)
  end

  def complete_changeset(user, params) do
    user
    |> cast(params, [:completed])
    |> validate_required([:completed])
    |> validate_inclusion(:completed, [true, false])
  end

  def register_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name, :uid])
    |> validate_required([:name, :uid])
    |> validate_length(:name, min: 3, max: 20)
    |> validate_number(:uid, greater_than: 9999999, less_than: 100000000, message: "must consist of exactly 8 numeric digits, without the leading 'U'")
    |> put_condition(params)
    |> unique_uid()
  end

  defp unique_uid(user) do
    if Application.fetch_env!(:collaboration, :allow_multiple_submissions?) do
      user
    else
      unique_constraint user, :uid,
        message: "This UID was already used for this experiment"
    end
  end

  defp put_condition(user, params) do
    case Map.get(params, "name") do
      "*test_1*" -> put_change(user, :condition, 1)
      "*test_2*" -> put_change(user, :condition, 2)
      "*test_3*" -> put_change(user, :condition, 3)
      "*test_4*" -> put_change(user, :condition, 4)
      "*test_5*" -> put_change(user, :condition, 5)
      "*test_6*" -> put_change(user, :condition, 6)
      "*test_7*" -> put_change(user, :condition, 7)
      "*test_8*" -> put_change(user, :condition, 8)
      _ -> put_change(user, :condition, Enum.random(1..8))
    end
  end

  defp put_credential(user, params) do
    if Map.has_key?(params, :credential) do
      cast_assoc user, :credential,
        with: &Credential.changeset/2,
        required: true
    else
      user
    end
  end
end
