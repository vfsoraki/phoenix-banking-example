defmodule Banking.Repo.Migrations.CreateTransactionLogs do
  use Ecto.Migration

  def change do
    create table(:transaction_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :before, :integer
      add :amount, :integer
      add :comment, :string
      add :bank_account_id, references(:bank_accounts, on_delete: :nothing, type: :binary_id)

      timestamps(updated_at: false)
    end

    create index(:transaction_logs, [:bank_account_id])
  end
end
