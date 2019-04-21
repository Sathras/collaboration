defmodule CollaborationWeb.SessionView do
  use CollaborationWeb, :view

  def survey_link(), do: Application.fetch_env!(:collaboration, :survey_link)

end
