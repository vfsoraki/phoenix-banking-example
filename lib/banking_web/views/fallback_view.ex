defmodule BankingWeb.FallbackView do
  use BankingWeb, :view

  def render("database_error.json", %{changeset: changeset}) do
    %{
      "status" => "failed",
      "errors" => render_errors(changeset)
    }
  end

  def render("general_error.json", %{reason: :not_found}) do
    %{
      "status" => "failed",
      "errors" => [
        "Could not find requested entity"
      ]
    }
  end

  def render("general_error.json", %{reason: :empty}) do
    %{
      "status" => "failed",
      "errors" => [
        "Can not find requested associated entities"
      ]
    }
  end
end
