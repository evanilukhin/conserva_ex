defmodule Conserva.ApiKey.RepoInteraction do
  import Ecto.Query
  alias Conserva.{Repo, ApiKey}
  
  def get_id_by_uuid(uuid) do
    Repo.one(from key in ApiKey, where: key.uuid == ^uuid, select: %{id: key.id})
  end
end
