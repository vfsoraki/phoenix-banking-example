defmodule Banking.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :phone, :string

      timestamps()
    end

    # We want emails and phones to be unique, each of them and also
    # a pair of them. This implies that a pair of phone/email is unique too.
    create unique_index(:users, [:email])
    create unique_index(:users, [:phone])
  end
end
