defmodule CollaborationWeb.UserCommander do
  use CollaborationWeb, :commander
  import CollaborationWeb.UserView

  defhandler toggle(socket, sender) do
    user = get_user! sender["data"]["id"]
    param = String.to_atom sender["data"]["param"]
    user = update_user!(user, %{param => !Map.get(user, param) })
    socket
    |> update!(data: "value", set: Atom.to_string(param), on: this(sender))
    |> update!(attr: "class", set: toggle_class(user, param), on: this(sender))
    |> update!(attr: "title", set: toggle_title(user, param), on: this(sender))
    |> update!(data: "original-title", set: toggle_title(user, param), on: this(sender))
  end
end
