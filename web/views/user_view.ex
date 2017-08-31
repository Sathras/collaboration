defmodule Collaboration.UserView do
  use Collaboration.Web, :view

  def render("user-admin.json", %{user: u}) do
    %{
      id:         u.id,
      email:      u.email,
      faux:       u.faux,
      username:   u.username,
      firstname:  u.firstname,
      lastname:   u.lastname,
      admin:      u.admin
    }
  end
end
