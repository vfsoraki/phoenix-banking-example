defmodule Banking.Schema.User do
  use Banking.Schema
  import Ecto.Changeset
  alias Banking.Schema.BankAccount
  alias Banking.Repo

  schema "users" do
    field :email, :string
    field :name, :string
    field :phone, :string

    has_many :accounts, BankAccount, foreign_key: :holder_id

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :phone])
    |> validate_required([:name, :email, :phone])
    |> unsafe_validate_unique(:email, Repo)
    |> unsafe_validate_unique(:phone, Repo)
    |> unique_constraint(:email)
    |> unique_constraint(:phone)
  end
end
