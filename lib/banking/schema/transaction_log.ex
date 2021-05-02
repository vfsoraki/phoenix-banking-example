defmodule Banking.Schema.TransactionLog do
  use Banking.Schema
  import Ecto.Changeset
  alias Banking.Schema.BankAccount

  schema "transaction_logs" do
    field :before, :integer
    field :amount, :integer
    field :comment, :string
    belongs_to :bank_account, BankAccount

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(%__MODULE__{} = transaction_log, attrs) do
    transaction_log
    |> cast(attrs, [:before, :amount, :comment])
    |> validate_required([:before, :amount])
  end
end
