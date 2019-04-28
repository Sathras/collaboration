defmodule Collaboration.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Collaboration.Accounts.Credential
  alias Collaboration.Contributions.{ Idea, Comment, Rating }

  schema "users" do

    field :terms_of_use, :boolean, virtual: true
    field :name, :string
    field :completed, :boolean
    field :condition, :integer
    field :uid, :integer
    timestamps()

    has_one :credential, Credential
    has_many :comments, Comment, on_delete: :delete_all
    has_many :ideas, Idea, on_delete: :delete_all
    has_many :ratings, Rating, on_delete: :delete_all

    many_to_many :likes, Comment, join_through: "likes", on_delete: :delete_all
  end

  @doc """
  Changeset for updating nonsensitive information.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:terms_of_use, :completed, :name, :uid])
    |> validate_inclusion(:completed, [true, false])
    |> validate_length(:name, min: 3, max: 20)
    |> validate_number(:uid, greater_than: 9999999, less_than: 100000000, message: "must consist of exactly 8 numeric digits, without the leading 'U'")
  end

  @doc """
  Changeset for creating bot/admin users.
  """
  def admin_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required([:name])
    |> put_change(:condition, 0)
    |> put_credential(attrs)
  end

  @doc """
  Changeset for creating experiment participants.
  """
  def register_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> validate_required([:name, :terms_of_use, :uid])
    |> validate_acceptance(:terms_of_use)
    |> put_condition(attrs)
    |> unique_uid()
  end


  # Selects a random condition for a user.
  # Users can also be forced into specific conditions based on name.
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

  # If credential was submitted create an admin user.
  # Otherwise create a bot user that is also in condition 0 but cannot login.
  defp put_credential(user, params) do
    if Map.has_key?(params, :credential) do
      cast_assoc user, :credential,
        with: &Credential.changeset/2,
        required: true
    else
      user
    end
  end

  # if :allow_multiple_submissions? is set in config,
  # prevent multiple sign ups with the same user id.
  defp unique_uid(user) do
    if Application.fetch_env!(:collaboration, :allow_multiple_submissions?) do
      user
    else
      unique_constraint user, :uid,
        message: "This UID was already used for this experiment"
    end
  end
end
