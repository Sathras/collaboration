defmodule Collaboration.TopicView do
  use Collaboration.Web, :view

  def render("topic-admin.json", %{topic: t}) do
    %{
      id:         t.id,
      title:      t.title,
      menutitle:  t.menutitle,
      order:      t.order,
      hidden:     t.hidden,
      closed:     t.closed
    }
  end
end
