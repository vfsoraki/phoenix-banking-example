defmodule BankingWeb.V1.AccountsController do
  use BankingWeb, :controller
  alias Banking.Context.Accounts

  action_fallback BankingWeb.V1.FallbackController

  def register(conn, %{"name" => _, "phone" => _, "email" => _} = params) do
    with {:ok, user} <- Accounts.register(params) do
      render(conn, :user, user: user)
    end
  end

  def info(conn, %{"user_id" => user_id}) do
    with {:ok, user} <- Accounts.get_user(user_id) do
      render(conn, :user, user: user)
    end
  end

  def open_account(conn, %{"user_id" => user_id, "balance" => _} = params) do
    with {:ok, user} <- Accounts.get_user(user_id),
         {:ok, bank_account} <- Accounts.create_bank_account(user, params) do
      render(conn, :account, account: bank_account)
    end
  end

  def get_account(conn, %{"user_id" => user_id, "account_id" => account_id}) do
    with {:ok, user} <- Accounts.get_user(user_id),
         {:ok, account} <- Accounts.get_account(user, account_id) do
      render(conn, :account, account: account)
    end
  end

  def list_accounts(conn, %{"user_id" => user_id}) do
    with {:ok, user} <- Accounts.get_user(user_id),
         {:ok, list} <- Accounts.get_bank_accounts(user) do
      render(conn, :accounts, accounts: list)
    end
  end

  def change_amount(conn, %{"account_id" => bank_account_id, "amount" => amount}) do
    with {:ok, {:ok, log}} <- Accounts.change_amount(bank_account_id, amount) do
      render(conn, :log, log: log)
    end
  end

  def list_transactions(conn, %{"account_id" => bank_account_id}) do
    with {:ok, account} <- Accounts.get_account(bank_account_id),
         {:ok, transactions} <- Accounts.get_account_log(account) do
      render(conn, :transactions, logs: transactions)
    end
  end
end
