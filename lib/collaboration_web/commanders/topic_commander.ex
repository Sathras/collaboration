defmodule CollaborationWeb.TopicCommander do
  use CollaborationWeb, :commander

  defhandler select_idea(socket, _sender, id) do
    ideas = peek socket, :ideas
    poke socket, current_idea: Enum.find(ideas, fn(x) -> x.id == id end)
    socket |> exec_js("$(#ideas time).timeago();")
  end

  def rate(socket, sender) do
    idea = peek socket, :current_idea
    user = peek socket, :current_user
    rating = rate_idea! user, idea, sender["value"]

    # if updated search rating and replace/insert in my_ratings
    if rating do
      my_ratings = peek socket, :my_ratings
      index = Enum.find_index(my_ratings, fn(x) -> x.id == rating.id end)
      my_ratings = if index,
        do: List.replace_at(my_ratings, index, rating),
        else: Enum.into(rating, my_ratings)
      poke socket, my_ratings: my_ratings
    end
  end

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
