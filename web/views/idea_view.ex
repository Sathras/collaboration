defmodule Collaboration.IdeaView do

  use Collaboration.Web, :view
  alias Collaboration.UserView

  def render("idea.json", %{idea: i}) do
    comments = [
      %{ id: 1, text: "asdfasdfasfd", user: %{firstname: "Alex", lastname: "test"}},
      %{ id: 2, text: "asdfsfdgdfgasdfasfd", user: %{firstname: "Berni", lastname: "test"}},
    ]

    %{
      id: i.id,
      inserted_at: i.inserted_at,
      title: i.title,
      description: i.description,
      comments: render_many(i.comments, Collaboration.CommentView, "comment.json"),
      user: UserView.displayName(i.user)
    }
  end

  defp stringifyComments(comments) do
    comments
    |> Enum.map(fn(c) ->
      """
        <li class='comment list-group-item' data-id='#{c.id}'>
          <strong>#{c.user.firstname} #{c.user.lastname}: </strong>
          #{c.text}
          <div class='pl-2 pull-right'>
            <i>4 minutes ago</i>
            <button type='button' class='btn btn-light btn-sm'>
              <i class='fa fa-trash' aria-hidden='true'></i>
            </button>
          </div>
        </li>
      """
      end)
    |> Enum.join("")
  end
end
