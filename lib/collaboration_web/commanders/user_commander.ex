defmodule CollaborationWeb.UserCommander do
  use CollaborationWeb, :commander
  import CollaborationWeb.UserView

  defhandler filter_condition(socket, sender) do
    condition = sender["value"]

    # load previous params and overwrite search string
    assigns = %{
      condition: condition,
      search: peek(socket, :search)
    }

    # load users and new page params
    result = list_users(assigns)

    # update template with new params and users
    poke socket, Map.to_list(%{
      condition: condition,
      page_number: result.page_number,
      page_size: result.page_size,
      total_entries: result.total_entries,
      total_pages: result.total_pages,
      users: result.entries
    })

    exec_js socket, "$('#users time').timeago()"
  end

  defhandler search(socket, sender) do
    search_string = sender["value"]
    search_string = if search_string === "", do: nil, else: search_string

    # load previous params and overwrite search string
    assigns = %{
      condition: peek(socket, :condition),
      search: search_string
    }
    # load users and new page params
    result = list_users(assigns)

    # update template with new params and users
    poke socket, Map.to_list(%{
      search: search_string,
      page_number: result.page_number,
      page_size: result.page_size,
      total_entries: result.total_entries,
      total_pages: result.total_pages,
      users: result.entries
    })

    exec_js socket, "$('#users time').timeago()"
  end

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
