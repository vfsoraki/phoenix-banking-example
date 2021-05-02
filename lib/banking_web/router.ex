defmodule BankingWeb.Router do
  use BankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankingWeb do
    pipe_through :api

    scope "/v1", V1 do
      scope "/accounts" do
        post "/", AccountsController, :register

        scope "/:user_id" do
          get "/", AccountsController, :info

          scope "/banking" do
            post "/", AccountsController, :open_account
            get "/", AccountsController, :list_accounts

            scope "/:account_id" do
              post "/", AccountsController, :change_amount
              get "/", AccountsController, :get_account
              get "/transactions", AccountsController, :list_transactions
            end
          end
        end
      end
    end
  end
end
