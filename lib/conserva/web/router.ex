defmodule Conserva.Router do
  use Plug.Router
  plug Conserva.Plug.Auth
  plug :match
  plug :dispatch
  plug Plug.Parsers, parsers: [:multipart]

  get "/api/v1/task/:id" do
    case Conserva.ConvertTask.RepoInteraction.get_task_info_by_id(id) do
      :nil -> send_resp(conn, 404, '')
      task_info -> send_resp(conn, 200, Poison.encode!(task_info))
    end
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
    send_resp(conn, 200, "delete task #{id} stub")
  end

  get "/api/v1/convert_combinations" do
    send_resp(conn, 200, "convert_combinations_stub")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
