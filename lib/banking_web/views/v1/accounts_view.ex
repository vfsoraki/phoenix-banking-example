defmodule BankingWeb.V1.AccountsView do
  use BankingWeb, :view
  alias Banking.Schema.User
  alias Banking.Schema.BankAccount
  alias Banking.Schema.TransactionLog

  def render("user.json", %{user: %User{} = user}) do
    render_user(user)
  end

  def render("account.json", %{account: account}) do
    render_account(account)
  end

  def render("accounts.json", %{accounts: accounts}) do
    render_many(accounts, __MODULE__, "account.json", as: :account)
  end

  def render("log.json", %{log: log}) do
    render_log(log)
  end

  def render("transactions.json", %{logs: logs}) do
    render_many(logs, __MODULE__, "log.json", as: :log)
  end

  defp render_log(%TransactionLog{} = log) do
    log_rendered = %{
      "id" => log.id,
      "before" => log.before,
      "amount" => log.amount,
      "after" => log.before + log.amount
    }

    case log.bank_account do
      %BankAccount{} = account ->
        Map.put(log_rendered, "bank_account", render_account(account))

      _ ->
        log_rendered
    end
  end

  defp render_user(%User{} = user) do
    %{
      "id" => user.id,
      "name" => user.name,
      "phone" => user.phone,
      "email" => user.email
    }
  end

  defp render_account(%BankAccount{} = account) do
    account_rendered = %{
      "id" => account.id,
      "balance" => account.balance
    }

    case account.holder do
      %User{} = holder ->
        Map.put(account_rendered, "holder", render_user(holder))

      _ ->
        account_rendered
    end
  end
end
