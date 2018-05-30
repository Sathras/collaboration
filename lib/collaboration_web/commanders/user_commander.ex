defmodule CollaborationWeb.UserCommander do
  use CollaborationWeb, :commander

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

  defhandler toggle_admin(socket, sender) do
    user = get_user!(sender["data"]["id"])
    case update_user(user, %{ admin: !user.admin }) do
      {:ok, user} ->
        target = ".toggle-admin[data-id=\"#{user.id}\""
        title = if user.admin, do: "Admin", else: "Normal User"

        socket
        |> update!(:class,
            toggle: "fa-user fa-user-plus text-primary text-muted", on: target)
        |> update!(attr: "title", set: title, on: target)

      {:error, _changeset} ->
        socket |> exec_js("console.log('Something went wrong!');")
    #     render(conn, "edit.html", changeset: changeset)
    end
  end
end
