defmodule Conserva.ApiKey do
  use Ecto.Schema

  schema "api_keys" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :comment, :string
  end
end
