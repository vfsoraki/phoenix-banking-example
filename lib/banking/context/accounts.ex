defmodule Banking.Context.Accounts do
  alias Banking.Schema.{
    User,
    BankAccount,
    TransactionLog
  }

  alias Banking.Repo
  alias Ecto.Changeset
  import Ecto.Query

  @spec register(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def register(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  @spec get_user(String.t()) :: {:ok, User.t()} | {:error, atom()}
  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      %User{} = user -> {:ok, user}
    end
  end

  @spec create_bank_account(User.t(), map) :: {:ok, BankAccount.t()} | {:error, Changeset.t()}
  def create_bank_account(%User{} = user, params) do
    user
    |> Ecto.build_assoc(:accounts)
    |> BankAccount.changeset(params)
    |> Repo.insert()
  end

  @spec get_bank_accounts(User.t()) :: {:ok, list(BankAccount.t())} | {:error, atom()}
  def get_bank_accounts(%User{id: user_id}) do
    case Repo.all(from bk in BankAccount, where: bk.holder_id == ^user_id) do
      [_ | _] = list ->
        {:ok, list}

      [] ->
        {:error, :empty}
    end
  end

  @spec change_amount(String.t(), integer()) ::
          {:ok, {:ok, TransactionLog.t()} | {:error, Changeset.t() | atom()}}
  @doc """
  Updates balance of a bank account. Balance can not become negative,
  and this function makes it a safe concurrent operation.

  `amount` can be negative or positive, to withdraw or deposit.
  """
  def change_amount(bank_account_id, amount) do
    Repo.transaction(fn ->
      lock_query =
        from bk in BankAccount,
          where: bk.id == ^bank_account_id,
          lock: "FOR UPDATE"

      # Locks bank_account's row until this transaction ends/fails
      # so we can safely read/update its balance.
      # This also can not result in a deadlock.
      # NOTE: Postgresql only
      case Repo.one(lock_query) do
        nil ->
          {:error, :not_found}

        %BankAccount{} = bank_account ->
          changeset =
            bank_account
            |> BankAccount.changeset(%{"balance" => bank_account.balance + amount})

          # Since bank_account is already locked, this update is safe, i.e.
          # concurrent updates won't happen until this transaction is completed/failed
          case Repo.update(changeset) do
            {:ok, updated_bank_account} ->
              updated_bank_account
              |> Ecto.build_assoc(:transaction_logs)
              |> TransactionLog.changeset(%{
                "before" => bank_account.balance,
                "amount" => amount
              })
              |> Repo.insert()

            # NOTE: Account balance should be read whenever it's needed and
            # users should not rely on returned log to show account's balance

            {:error, _changeset} = error ->
              error
          end
      end
    end)
  end

  @spec get_account(User.t(), String.t()) :: {:ok, BankAccount.t()} | {:error, atom()}
  @doc """
  Get a bank account, only if the bank account is owned by provided user.
  """
  def get_account(%User{id: user_id}, account_id) do
    case get_account(account_id) do
      {:ok, %BankAccount{holder_id: ^user_id} = account} -> {:ok, account}
      _ -> {:error, :not_found}
    end
  end

  @spec get_account(String.t()) :: {:ok, BankAccount.t()} | {:error, atom()}
  def get_account(id) do
    case Repo.get(BankAccount, id) do
      nil -> {:error, :not_found}
      %BankAccount{} = account -> {:ok, account}
    end
  end

  @spec get_account_log(BankAccount.t()) :: {:ok, list(TransactionLog.t())} | {:error, atom()}
  def get_account_log(%BankAccount{id: account_id}) do
    query =
      from log in TransactionLog,
        where: log.bank_account_id == ^account_id,
        order_by: [desc: :inserted_at]

    case Repo.all(query) do
      [_ | _] = list ->
        {:ok, list}

      [] ->
        {:error, :empty}
    end
  end
end
