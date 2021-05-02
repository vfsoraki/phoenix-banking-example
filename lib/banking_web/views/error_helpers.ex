defmodule BankingWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  alias Ecto.Changeset

  @doc """
  Translates an error message.
  """
  def translate_error({msg, opts}) do
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      string =
        case value do
          l when is_list(l) -> Enum.join(l, ",")
          o -> to_string(o)
        end

      String.replace(acc, "%{#{key}}", string)
    end)
  end

  @doc """
  Renders errors of a changeset into a JSONable map.
  """
  def render_errors(%Changeset{} = changeset) do
    Changeset.traverse_errors(changeset, &translate_error/1)
  end
end
