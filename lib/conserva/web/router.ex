defmodule Conserva.Router do
  use Plug.Router

  plug Plug.Parsers, parsers: [:multipart], pass: ["*/*"], length: Application.fetch_env!(:conserva, :max_file_size)
  plug Conserva.Plug.Auth
  plug Conserva.Plug.NewTaskFetcher, paths: ["post /api/v1/task"]
  plug :match
  plug :dispatch

  require IEx

  get "/api/v1/task/:id" do
    case Conserva.ConvertTask.RepoInteraction.get_task_info_by_id(id) do
      :nil -> send_resp(conn, 404, '')
      task_info -> send_resp(conn, 200, Poison.encode!(task_info))
    end
  end

  post "/api/v1/task" do
    case Conserva.ConvertTask.RepoInteraction.create_new_task(conn.assigns[:changeset]) do
      {:ok, saved_task} ->
        send_resp(conn, 200, "#{saved_task.id}")
      {:error, unsaved_task} ->
        File.rm(conn.assigns[:potential_file_path])
        send_resp(conn, 422, "")
    end
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
