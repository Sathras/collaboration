defmodule Collaboration.User do

  use Collaboration.Web, :model
  import Comeonin.Bcrypt, only: [checkpw: 2]

  schema "users" do
    field :email, :string
    field :firstname, :string
    field :lastname, :string
    field :password, :string, virtual: true
    field :password_confirm, :string, virtual: true
    field :password_old, :string, virtual: true
    field :password_hash, :string
    field :username, :string
    field :admin, :boolean, default: false
    field :faux, :boolean, default: false
    has_many :ideas, Collaboration.Idea
    timestamps()
  end

  @doc """
    password
    at least 1 number and alphapetic

    username
    no _ or . at the beginning
    no __ or _. or ._ or .. inside,
    allowed characters: a-zA-Z0-9._
    no _ or . at the end
  """

  def changeset_login(struct, params) do
    struct
    |> cast(params, ~w(email password))
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)
    |> validate_format(:password, ~r/^(\w*(\d+[a-zA-Z]|[a-zA-Z]+\d)\w*)+$/)
    |> validate_length(:password, min: 8)
  end

  # changeset for editing profile
  def changeset_update(struct, params, curr_pass) do
    struct
    |> cast(params, ~w(email firstname lastname password password_old password_confirm username admin faux))
    |> validate_required([:email])
    |> validate_format(:email, ~r/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)
    |> validate_length(:firstname, min: 3, max: 20)
    |> validate_length(:lastname, min: 3, max: 20)
    |> password_needed(curr_pass)
    |> password_change()
    |> username_change(self)
    |> unique_constraint(:email)
  end

  def changeset_register(struct, params \\ %{}) do
    struct
    |> changeset_login(params)
    |> cast(params, ~w(firstname lastname username password_confirm))
    |> validate_required([:username, :password_confirm])
    |> validate_length(:firstname, min: 3, max: 20)
    |> validate_length(:lastname, min: 3, max: 20)
    |> validate_length(:username, min: 3, max: 20)
    |> password_confirmed()
    |> validate_format(:email, ~r/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_pass_hash()
  end

  defp password_confirmed(changeset) do
    if get_field(changeset, :password) != get_field(changeset, :password_confirm),
      do: add_error(changeset, :password_confirm, "does not match"),
      else: changeset
  end

  defp password_match(changeset, curr_pass) do

    password_old = get_change(changeset, :password_old)
    cond do
      password_old && checkpw(password_old, curr_pass) ->
        changeset
      true ->
        add_error(changeset, :password_old, "Your password is incorrect")
    end
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ -> # that underscore matches the error case
        changeset
    end
  end

  defp password_change(changeset) do
    if get_change(changeset, :password), do:
      changeset
      |> validate_format(:password, ~r/^(\w*(\d+[a-zA-Z]|[a-zA-Z]+\d)\w*)+$/)
      |> validate_length(:password, min: 8)
      |> validate_required([:password_confirm])
      |> password_confirmed()
      |> put_pass_hash(),
    else: changeset
  end

  defp username_change(changeset, self) do
    cond do
      get_change(changeset, :username) && !self ->
        add_error(changeset, :username, "You cannot change your username")

      get_change(changeset, :username) ->
        changeset
        |> validate_required([:username])
        |> validate_length(:username, min: 3, max: 20)
        |> unique_constraint(:username)

      true -> changeset
    end
  end

  defp password_needed(changeset, curr_pass) do
    if curr_pass, do:
      changeset
      |> validate_required([:password_old])
      |> password_match(curr_pass),
    else: changeset
  end
end
