defmodule CollaborationWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  alias Phoenix.HTML.Form

  # Automatically add HTML5 validations to form fields.

  def textarea(form, field, opts \\ []) do
    Form.textarea(form, field, opts ++ Form.input_validations(form, field))
  end

  def field_class(form, field) do
    cond do
      is_nil(form.source.action) -> "form-control"
      has_error?(form, field) -> "form-control is-invalid"
      true -> "form-control is-valid"
    end
  end

  @doc """
  Generates a map with all invalid fields and their first error
  """
  def error_map(changeset),
    do: Map.new(changeset.errors, fn {k, v} -> {k, translate_error(v)} end)

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:div, translate_error(error), class: "invalid-feedback")
    end)
  end

  @doc """
  Checks whether field has an error in changeset.
  """
  def has_error?(form, field), do: Keyword.has_key?(form.errors, field)

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext "errors", "is invalid"
    #
    #     # Translate the number of files with plural rules
    #     dngettext "errors", "1 file", "%{count} files", count
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(
        CollaborationWeb.Gettext,
        "errors",
        msg,
        msg,
        count,
        opts
      )
    else
      Gettext.dgettext(CollaborationWeb.Gettext, "errors", msg, opts)
    end
  end
end
