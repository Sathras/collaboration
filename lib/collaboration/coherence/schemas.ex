defmodule Collaboration.Coherence.Schemas do

  use Coherence.Config

  import Ecto.Query

  @user_schema Config.user_schema
  @repo        Config.repo

  def list_user do
    @repo.all @user_schema
  end

  def list_user(page_size, page_number, search_term) do
    query = from u in @user_schema, select: struct(u, [:name, :email ])
    query = add_filter(query, search_term)
    Collaboration.Repo.paginate(query, page: page_number, page_size: page_size)
  end

  defp add_filter(query, search_term) when search_term == nil or search_term == "", do: query
  defp add_filter(query, original_search_term) do
    search_term = "#{original_search_term}%"
    from u in query,
    where: like(u.email, ^search_term) or like(u.name, ^search_term)
  end

  def list_by_user(opts) do
    @repo.all query_by(@user_schema, opts)
  end

  def get_by_user(opts) do
    @repo.get_by @user_schema, opts
  end

  def get_user(id) do
    @repo.get @user_schema, id
  end

  def get_user!(id) do
    @repo.get! @user_schema, id
  end

  def get_user_by_email(email) do
    @repo.get_by @user_schema, email: email
  end

  def change_user(struct, params, changeset_variation) do
    @user_schema.changeset struct, params, changeset_variation
  end

  def change_user(struct, params) do
    @user_schema.changeset struct, params
  end

  def change_user(params) do
    @user_schema.changeset @user_schema.__struct__, params
  end

  def change_user do
    @user_schema.changeset @user_schema.__struct__, %{}
  end

  def create_user(params) do
    @repo.insert change_user(params)
  end

  def create_user!(params) do
    @repo.insert! change_user(params)
  end

  def toggle(user, params) do
    @repo.update change_user(user, params, :toggle)
  end

  def update_user(user, params) do
    @repo.update change_user(user, params)
  end

  def update_user!(user, params) do
    @repo.update! change_user(user, params)
  end

  Enum.each [Collaboration.Coherence.Invitation, Collaboration.Coherence.Rememberable], fn module ->

    name =
      module
      |> Module.split
      |> List.last
      |> String.downcase

    def unquote(String.to_atom("list_#{name}"))() do
      @repo.all unquote(module)
    end

    def unquote(String.to_atom("list_#{name}"))(%Ecto.Query{} = query) do
      @repo.all query
    end

    def unquote(String.to_atom("list_by_#{name}"))(opts) do
      @repo.all query_by(unquote(module), opts)
    end

    def unquote(String.to_atom("get_#{name}"))(id) do
      @repo.get unquote(module), id
    end

    def unquote(String.to_atom("get_#{name}!"))(id) do
      @repo.get! unquote(module), id
    end

    def unquote(String.to_atom("get_by_#{name}"))(opts) do
      @repo.get_by unquote(module), opts
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
      @repo.insert unquote(module).new_changeset(params)
    end

    def unquote(String.to_atom("create_#{name}!"))(params) do
      @repo.insert! unquote(module).new_changeset(params)
    end

    def unquote(String.to_atom("update_#{name}"))(struct, params) do
      @repo.update unquote(module).changeset(struct, params)
    end

    def unquote(String.to_atom("update_#{name}!"))(struct, params) do
      @repo.update! unquote(module).changeset(struct, params)
    end

    def unquote(String.to_atom("delete_#{name}"))(struct) do
      @repo.delete struct
    end
  end

  def query_by(schema, opts) do
    Enum.reduce opts, schema, fn {k, v}, query ->
      where(query, [b], field(b, ^k) == ^v)
    end
  end

  def delete_all(%Ecto.Query{} = query) do
    @repo.delete_all query
  end

  def delete_all(module) when is_atom(module) do
    @repo.delete_all module
  end

  def create(%Ecto.Changeset{} = changeset) do
    @repo.insert changeset
  end

  def create!(%Ecto.Changeset{} = changeset) do
    @repo.insert! changeset
  end

  def update(%Ecto.Changeset{} = changeset) do
    @repo.update changeset
  end

  def update!(%Ecto.Changeset{} = changeset) do
    @repo.update! changeset
  end

  def delete(schema) do
    @repo.delete schema
  end

  def delete!(schema) do
    @repo.delete! schema
  end

end