defmodule Conserva.Plug.Auth do
  use Plug.Builder
  plug :authentification

  defp authentification(conn, _opts) do
    api_key = Plug.Conn.fetch_query_params(conn).params |> Map.get("api_key")
    case Ecto.UUID.cast(api_key) do
      {:ok, uuid} -> set_api_key_id(conn, uuid)
      :error -> send_resp(conn, 403, '') |> halt
    end
  end

  defp set_api_key_id(conn, uuid) do
    case Conserva.ApiKey.RepoInteraction.get_id_by_uuid(uuid) do
      %{id: id} -> assign(conn, :api_key_id, id)
      :nil -> send_resp(conn, 403, '') |> halt
    end
  end
end
