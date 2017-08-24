defmodule Collaboration.UserView do
  use Collaboration.Web, :view

  def render("user-public.json", %{user: u}) do
    %{
      id: u.id,
      firstname: u.firstname,
      lastname: u.lastname
    }
  end
end
