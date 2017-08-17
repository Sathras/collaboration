defmodule Collaboration.User do
  use Collaboration.Web, :model

  schema "users" do

    field :email, :string
    field :firstname, :string
    field :lastname, :string
    field :password, :string, virtual: true
    field :password_confirm, :string, virtual: true
    field :password_old, :string, virtual: true
    field :password_hash, :string
    field :username, :string

    timestamps()
  end

  @doc """
    password
    at least 1 number and alphapetic
    allowed characters: a-zA-Z0-9$@$!%*?&

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
    |> validate_format(:password, ~r/^(?=.*[A-Za-z])(?=.*[0-9$@$!%*#?&])[A-Za-z0-9$@$!%*#?&]{8,100}$/)
  end

  def changeset_edit(struct, params) do
    struct
    |> cast(params, ~w(email firstname lastname password password_old password_confirm))
    |> validate_required([:password_old])
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

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ -> # that underscore matches the error case
        changeset
    end
  end
end
