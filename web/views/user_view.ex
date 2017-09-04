defmodule Collaboration.UserView do
  use Collaboration.Web, :view

  def displayName(user) do
    # combine the avaiable userdata into a name string
    cond do
      user.firstname && user.lastname -> user.firstname <> " " <>
        (user.lastname |> String.first() |> String.capitalize()) <> "."
      user.firstname -> user.firstname
      true -> user.username
    end
  end

  def render("user-name.json", %{user: u}) do
    %{
      id:         u.id,
      name:       displayName(u)
    }
  end

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
