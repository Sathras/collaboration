defmodule Collaboration.Coherence.Schemas do
  use Coherence.Config
  import Ecto.Query
  alias Phoenix.View
  alias Collaboration.Repo
  alias CollaborationWeb.UserView

  @user_schema Config.user_schema()
  @repo Config.repo()

  def list_participants() do
    from( u in @user_schema,
      select: map(u, [:condition, :email, :inserted_at, :name]),
      order_by: u.inserted_at,
      where: u.admin == false and u.peer == false,
      limit: 2000
    ) |> Repo.all()
  end

  def list_users() do
    from( u in @user_schema,
      select: map(u, [:admin, :peer, :email, :id, :inserted_at, :name]),
      order_by: u.inserted_at,
      where: u.admin or u.peer,
      limit: 100
    ) |> Repo.all()
  end

  def select_user_ids(types, user_id \\ nil) do
    query = from(u in @user_schema, select: u.id)
    query = if Enum.member?(types, :admins), do: or_where(query, admin: true), else: query
    query = if Enum.member?(types, :peers), do: or_where(query, peer: true), else: query
    query = if user_id, do: or_where(query, id: ^user_id), else: query
    Repo.all(query)
  end

  def select_random_user(condition, user_id) do
    query = from u in @user_schema, order_by: fragment("RANDOM()"), limit: 1
    case condition do
      3 -> from(u in query, where: u.id != ^user_id and u.peer)
      4 -> from(u in query, where: u.id != ^user_id and u.admin)
      _ -> query
    end
    |> Repo.all()
    |> List.first()
  end

  def list_by_user(opts) do
    @repo.all(query_by(@user_schema, opts))
  end

  def get_by_user(opts) do
    @repo.get_by(@user_schema, opts)
  end

  def get_user(id) do
    @repo.get(@user_schema, id)
  end

  def get_user!(id) do
    @repo.get!(@user_schema, id)
  end

  def get_user_by_email(email) do
    @repo.get_by(@user_schema, email: email)
  end

  def is_admin?(id) do
    @repo.one from(u in @user_schema, select: u.admin, where: u.id == ^id)
  end

  def change_user(struct, params, changeset_variation) do
    @user_schema.changeset(struct, params, changeset_variation)
  end

  def change_user(:experiment, params) do
    @user_schema.changeset(@user_schema.__struct__, params, :experiment)
  end

  def change_user(struct, params) do
    @user_schema.changeset(struct, params)
  end

  def change_user(params) do
    @user_schema.changeset(@user_schema.__struct__, params)
  end

  def change_user do
    @user_schema.changeset(@user_schema.__struct__, %{})
  end

  def create_user(params) do
    @repo.insert(change_user(params))
  end

  def create_user_for_experiment(params) do
    @repo.insert(change_user(:experiment, params))
  end

  def create_user!(params) do
    @repo.insert!(change_user(params))
  end

  def render_user(user) do
    View.render_one(user, UserView, "user.json")
  end

  def toggle(user, params) do
    @repo.update(change_user(user, params, :toggle))
  end

  def update_user(user, params) do
    @repo.update(change_user(user, params))
  end

  def update_user!(user, params) do
    @repo.update!(change_user(user, params))
  end

  def increase_feedback_sequence(_user) do

  end

  Enum.each(
    [Collaboration.Coherence.Invitation, Collaboration.Coherence.Rememberable],
    fn module ->
      name =
        module
        |> Module.split()
        |> List.last()
        |> String.downcase()

      def unquote(String.to_atom("list_#{name}"))() do
        @repo.all(unquote(module))
      end

      def unquote(String.to_atom("list_#{name}"))(%Ecto.Query{} = query) do
        @repo.all(query)
      end

      def unquote(String.to_atom("list_by_#{name}"))(opts) do
        @repo.all(query_by(unquote(module), opts))
      end

      def unquote(String.to_atom("get_#{name}"))(id) do
        @repo.get(unquote(module), id)
      end

      def unquote(String.to_atom("get_#{name}!"))(id) do
        @repo.get!(unquote(module), id)
      end

      def unquote(String.to_atom("get_by_#{name}"))(opts) do
        @repo.get_by(unquote(module), opts)
      end

      def unquote(String.to_atom("change_#{name}"))(struct, params) do
        unquote(module).changeset(struct, params)
      end

      def unquote(String.to_atom("change_#{name}"))(params) do
        unquote(module).new_changeset(params)
      end

      def unquote(String.to_atom("change_#{name}"))() do
        unquote(module).new_changeset(%{})
      end

      def unquote(String.to_atom("create_#{name}"))(params) do
        @repo.insert(unquote(module).new_changeset(params))
      end

      def unquote(String.to_atom("create_#{name}!"))(params) do
        @repo.insert!(unquote(module).new_changeset(params))
      end

      def unquote(String.to_atom("update_#{name}"))(struct, params) do
        @repo.update(unquote(module).changeset(struct, params))
      end

      def unquote(String.to_atom("update_#{name}!"))(struct, params) do
        @repo.update!(unquote(module).changeset(struct, params))
      end

      def unquote(String.to_atom("delete_#{name}"))(struct) do
        @repo.delete(struct)
      end
    end
  )

  def query_by(schema, opts) do
    Enum.reduce(opts, schema, fn {k, v}, query ->
      where(query, [b], field(b, ^k) == ^v)
    end)
  end

  def delete_all(%Ecto.Query{} = query) do
    @repo.delete_all(query)
  end

  def delete_all(module) when is_atom(module) do
    @repo.delete_all(module)
  end

  def create(%Ecto.Changeset{} = changeset) do
    @repo.insert(changeset)
  end

  def create!(%Ecto.Changeset{} = changeset) do
    @repo.insert!(changeset)
  end

  def update(%Ecto.Changeset{} = changeset) do
    @repo.update(changeset)
  end

  def update!(%Ecto.Changeset{} = changeset) do
    @repo.update!(changeset)
  end

  def delete(schema) do
    @repo.delete(schema)
  end

  def delete!(schema) do
    @repo.delete!(schema)
  end
end
