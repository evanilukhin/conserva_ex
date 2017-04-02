defmodule Conserva.Router do
  use Plug.Router
  plug :autorization
  plug :match
  plug :dispatch
  plug Plug.Parsers, parsers: [:multipart]
  require IEx
  import Ecto.Query
  alias Conserva.{Repo, ApiKey, ConvertTask}

  plug Plug.Parsers, parsers: [:multipart]

  get "/api/v1/task/:id" do
    send_resp(conn, 200, "get task #{id}")
  end

  get "/api/v1/async_convert" do
    send_resp(conn, 200, "async_convert")
  end

  post "/api/v1/task" do
    {_, body, conn} = Plug.Conn.read_body(conn, length: Application.fetch_env!(:conserva, :max_file_size))
    input_extension = Plug.Conn.fetch_query_params(conn).params |> Map.get("input_extension")
    file_name = Integer.to_string(:os.system_time ) <> ".#{input_extension}"
    {:ok, file} ="#{Application.fetch_env!(:conserva, :file_storage_path)}/#{file_name}" |> File.open([:write])
    IO.binwrite file, body
    File.close file
    send_resp(conn, 200, "post task")
  end

  delete "/api/v1/task/:id" do
    send_resp(conn, 200, "delete task #{id}")
  end

  get "/api/v1/convert_combinations" do
    send_resp(conn, 200, "convert_combinations")
  end

  defp autorization(conn, opts) do
    api_key = Plug.Conn.fetch_query_params(conn).params |> Map.get("api_key")
    case Ecto.UUID.cast(api_key) do
      {:ok, uuid} -> set_api_key_id(conn, uuid)
      :error -> send_resp(conn, 403, '') |> halt
    end
  end

  defp set_api_key_id(conn, uuid) do
    case Repo.one(from key in ApiKey, where: key.uuid == ^uuid, select: %{id: key.id}) do
      %{id: id} -> assign(conn, :api_key_id, id)
      :nil -> send_resp(conn, 403, '') |> halt
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
