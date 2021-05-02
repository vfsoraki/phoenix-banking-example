defmodule Banking.Schema.BankAccount do
  use Banking.Schema
  import Ecto.Changeset
  alias Banking.Schema.User
  alias Banking.Schema.TransactionLog

  schema "bank_accounts" do
    # This integer actually hold two decimal points of USD,
    # e.g $12.56 would be saved as 1256 in database.
    # This is a simple strategy to escape rounding errors of floating point
    # numbers. For more complex situations, other strategies must be used.
    field :balance, :integer

    belongs_to :holder, User
    has_many :transaction_logs, TransactionLog

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = bank_account, attrs) do
    bank_account
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
    |> validate_number(:balance, greater_than: 0)
  end
end
