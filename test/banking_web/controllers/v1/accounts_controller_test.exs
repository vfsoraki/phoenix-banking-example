defmodule BankingWeb.V1.AccountsControllerTest do
  use BankingWeb.ConnCase

  @user_params %{
    "name" => "FooBar",
    "phone" => "123123",
    "email" => "foo@bar.com"
  }

  @account_params %{"balance" => 1000}

  @log_params %{"before" => @account_params["balance"], "amount" => 10}

  test "register user", %{conn: conn} do
    conn = register_user(conn)
    json = json_response(conn, 200)

    assert_info_user(json, @user_params)
  end

  test "does not register duplicate phone", %{conn: conn} do
    register_user(conn)
    conn = register_user(conn, %{"email" => "bar@foo.com"})
    json = json_response(conn, 400)

    assert json["status"] == "failed"
    assert length(json["errors"]["phone"]) == 1
  end

  test "does not register duplicate email", %{conn: conn} do
    register_user(conn)
    conn = register_user(conn, %{"phone" => "321312"})
    json = json_response(conn, 400)

    assert json["status"] == "failed"
    assert length(json["errors"]["email"]) == 1
  end

  test "get user info", %{conn: conn} do
    conn = register_user(conn)
    %{"id" => user_id} = json_response(conn, 200)

    conn = get(conn, "/api/v1/accounts/#{user_id}")
    info_json = json_response(conn, 200)
    assert_info_user(info_json, @user_params)
  end

  test "open account", %{conn: conn} do
    conn = register_user(conn)
    %{"id" => user_id} = json_response(conn, 200)

    conn = open_account(conn, user_id)
    json = json_response(conn, 200)
    assert_info_account(json, @account_params)
  end

  test "list accounts", %{conn: conn} do
    conn = register_user(conn)
    %{"id" => user_id} = json_response(conn, 200)

    conn = open_account(conn, user_id)
    %{"id" => account_id} = json_response(conn, 200)

    conn = list_accounts(conn, user_id)
    json = json_response(conn, 200)

    assert [account] = json
    assert account["id"] == account_id
  end

  test "change account amount", %{conn: conn} do
    conn = register_user(conn)
    %{"id" => user_id} = json_response(conn, 200)

    conn = open_account(conn, user_id)
    %{"id" => account_id} = json_response(conn, 200)

    conn = change_amount(conn, {user_id, account_id}, @log_params["amount"])
    json = json_response(conn, 200)

    assert_info_log(json, @log_params)

    conn = get_account(conn, {user_id, account_id})
    json = json_response(conn, 200)

    assert json["balance"] == @account_params["balance"] + @log_params["amount"]
  end

  test "can't change amount more than they have", %{conn: conn} do
    conn = register_user(conn)
    %{"id" => user_id} = json_response(conn, 200)

    conn = open_account(conn, user_id)
    %{"id" => account_id} = json_response(conn, 200)

    conn = change_amount(conn, {user_id, account_id}, -1001)
    json = json_response(conn, 400)

    assert json["status"] == "failed"

    conn = get_account(conn, {user_id, account_id})
    json = json_response(conn, 200)

    assert json["balance"] == @account_params["balance"]
  end

  test "list transactions", %{conn: conn} do
    conn = register_user(conn)
    %{"id" => user_id} = json_response(conn, 200)

    conn = open_account(conn, user_id)
    %{"id" => account_id} = json_response(conn, 200)

    change_amount(conn, {user_id, account_id}, @log_params["amount"])
    change_amount(conn, {user_id, account_id}, @log_params["amount"])

    conn = list_transactions(conn, {user_id, account_id})
    json = json_response(conn, 200)

    assert length(json) == 2
  end

  defp register_user(conn, params \\ %{}) do
    post(conn, "/api/v1/accounts", Map.merge(@user_params, params))
  end

  defp open_account(conn, user_id, params \\ %{}) do
    post(conn, "/api/v1/accounts/#{user_id}/banking", Map.merge(@account_params, params))
  end

  defp get_account(conn, {user_id, account_id}) do
    get(conn, "/api/v1/accounts/#{user_id}/banking/#{account_id}")
  end

  defp list_accounts(conn, user_id) do
    get(conn, "/api/v1/accounts/#{user_id}/banking")
  end

  defp change_amount(conn, {user_id, account_id}, amount) do
    post(conn, "/api/v1/accounts/#{user_id}/banking/#{account_id}", %{"amount" => amount})
  end

  defp list_transactions(conn, {user_id, account_id}) do
    get(conn, "/api/v1/accounts/#{user_id}/banking/#{account_id}/transactions")
  end

  defp assert_info_user(json, params) do
    assert json["name"] == params["name"]
    assert json["phone"] == params["phone"]
    assert json["email"] == params["email"]
  end

  defp assert_info_account(json, params) do
    assert json["balance"] == params["balance"]
  end

  defp assert_info_log(json, params) do
    assert json["before"] == params["before"]
    assert json["amount"] == params["amount"]
  end
end
