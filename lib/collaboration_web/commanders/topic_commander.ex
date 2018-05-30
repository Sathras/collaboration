defmodule CollaborationWeb.TopicCommander do
  use CollaborationWeb, :commander

  defhandler toggle(socket, sender) do
    param = sender["data"]["param"]
    value = !sender["data"]["value"]
    topic = get_topic!(sender["data"]["id"])

    case update_topic(topic, Map.put(%{}, param, value)) do
      {:ok, topic} ->
        target = "[data-id=\"#{topic.id}\"][data-param=\"#{param}\"]"

        case param do
          "featured" ->
            socket |> update!(:class, toggle: "text-primary text-muted", on: target)
          "open" ->
            socket |> update!(:class, toggle: "fa-unlock-alt text-success fa-lock", on: target)
          "published" ->
            socket |> update!(:class, toggle: "fa-eye fa-eye-slash text-muted", on: target)
        end

        socket |> update!(attr: "data-value", set: value, on: target)

      {:error, _changeset} ->
        socket |> exec_js("console.log('Something went wrong!');")
    end
  end
end
