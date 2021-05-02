defmodule Banking.Context.AccountsTest do
  use Banking.DataCase
  alias Banking.Context.Accounts

  @user_params %{
    "name" => "FooBar",
    "phone" => "123123",
    "email" => "foo@bar.com"
  }

  @account_params %{"balance" => 1000}

  @change_amount 10

  test "can change amount of a balance" do
    {:ok, user} = register_user()
    {:ok, account} = create_account(user)

    {:ok, {:ok, log}} = Accounts.change_amount(account.id, @change_amount)

    assert @account_params["balance"] == log.before
    assert @change_amount == log.amount
  end

  test "amount can not be less than or equal to zero" do
    {:ok, user} = register_user()
    {:ok, account} = create_account(user)

    assert {:ok, {:error, _}} = Accounts.change_amount(account.id, -1000)

    {:ok, updated_account} = Accounts.get_account(account.id)
    assert updated_account.balance == account.balance
  end

  test "Multiple concurrent change amounts work as expected" do
    {:ok, user} = register_user()
    {:ok, account} = create_account(user)

    tasks =
      for _ <- 1..100 do
        Task.async(fn ->
          Accounts.change_amount(account.id, -10)
        end)
      end

    for task <- tasks do
      Task.await(task, 1000)
    end

    # 99 of tasks should succeed, and one of them should fail,
    # leaving 10 as the final balance of the account

    {:ok, updated_account} = Accounts.get_account(account.id)
    assert updated_account.balance == 10
  end

  def register_user(params \\ %{}) do
    Accounts.register(Map.merge(@user_params, params))
  end

  def create_account(user, params \\ %{}) do
    Accounts.create_bank_account(user, Map.merge(@account_params, params))
  end
end
