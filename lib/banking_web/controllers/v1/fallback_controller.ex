defmodule BankingWeb.V1.FallbackController do
  use BankingWeb, :controller
  alias BankingWeb.FallbackView

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(400)
    |> put_view(FallbackView)
    |> render(:database_error, changeset: changeset)
  end

  def call(conn, {:ok, {:error, %Ecto.Changeset{}} = error}) do
    call(conn, error)
  end

  def call(conn, {:error, reason}) when is_atom(reason) do
    conn
    |> put_status(400)
    |> put_view(FallbackView)
    |> render(:general_error, reason: reason)
  end
end
