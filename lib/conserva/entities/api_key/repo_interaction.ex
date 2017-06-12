defmodule Conserva.ApiKey.RepoInteraction do
  import Ecto.Query
  alias Conserva.{Repo, ApiKey}

  def get_id_by_uuid(uuid) do
    Repo.one(from key in ApiKey, where: key.uuid == ^uuid, select: %{id: key.id})
  end

  def create(options) do
    api_key =
      %ApiKey{uuid: Ecto.UUID.generate(),
              name: options[:name],
              comment: options[:comment]}
    Repo.insert(api_key)
  end
end
