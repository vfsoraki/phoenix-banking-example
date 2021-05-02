defmodule Banking.Repo.Migrations.CreateBankAccounts do
  use Ecto.Migration

  def change do
    create table(:bank_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :balance, :integer
      add :holder_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:bank_accounts, [:holder_id])
  end
end
