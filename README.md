# Banking

An example API using Phoenix framework, that simulates a banking API.

To start the server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can test the api at `localhost:4000`.

To see how to use the API, see the tests at `test/banking_web/controllers/v1/accounts_controllers_test.exs`.

All APIs return HTTP 200 if they're successful, or 400 in case of parameter/validation error.

In case of HTTP 200, the requested entity/entities are returned directly.

In case of HTTP 400, the response has the following format:

```
{
    "status" => "failed",
    "errors" => [
        # an object
        {<error_key> => [<error_message>, <error_message>]},
        # or just a string
        <error_message>
        ...
    ]
}
```

There is no authentication/authorization mechanism implemented. This is solely an example for
Phoenix framework, not an example on how to implement a banking system.

Reference of the API:

- `POST /api/v1/accounts`: Registers a user
- `GET /api/v1/accounts/:id`: Returns information of a user
- `POST /api/v1/accounts/:id/banking`: Opens a banking account for the user
- `GET /api/v1/accounts/:id/banking/:account_id`: Returns information about a banking account of a user
- `GET /api/v1/accounts/:id/banking/:account_id/transactions`: Returns information about transactions of a banking account of a user
- `POST /api/v1/accounts/:id/banking/:account_id`: Withdraw/deposit from an account.
