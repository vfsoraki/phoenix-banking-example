defmodule Banking.Schema do
  @moduledoc """
  A module to be `use`d by our schemas.
  Sets up basic configuration for schemas.
  """

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      @type t() :: %__MODULE__{}
    end
  end
end
