defmodule Conserva.Router do
  use Plug.Router
  require Logger

  plug Plug.Parsers, parsers: [:multipart], pass: ["*/*"], length: Application.fetch_env!(:conserva, :max_file_size)
  plug Conserva.Plug.Auth
  plug Conserva.Plug.NewTaskFetcher, paths: ["post /api/v1/task"]
  plug :match
  plug :dispatch

  alias Conserva.ConvertTask

  require IEx

  get "/api/v1/task/:id" do
    case ConvertTask.RepoInteraction.get_info_by_id(id) do
      :nil -> send_resp(conn, 404, '')
      task_info -> send_resp(conn, 200, Poison.encode!(task_info))
    end
  end

  get "/api/v1/task/:id/download" do
    case ConvertTask.RepoInteraction.get_by_id(id) do
      :nil -> send_resp(conn, 404, "Task does not exist")
      task -> try_download_task(conn,task)
    end
  end

  defp try_download_task(conn, task) do
    cond do
      task.state == "finished" -> download_task(conn, task)
      true -> send_resp(conn, 202, "")
    end
  end

  defp download_task(conn, task) do
    file_name = task.converted_file
    change_params = %{downloads_count: task.downloads_count + 1, last_download_time: Ecto.DateTime.utc}
    changes = ConvertTask.changeset(task, change_params)
    case Conserva.Repo.update(changes) do
      {:ok, task} ->
        Logger.info("Sending result file for task: #{task.id}", subsystem: :api)
        conn |>
        put_resp_header("Content-Disposition", "filename=\"#{file_name}\"") |>
        send_file(200, "#{Application.fetch_env!(:conserva, :file_storage_path)}/#{task.converted_file}")
      {:error, changes} ->
        Logger.error("Fail update task #{task.id} state before downloading. Extended info: #{changes.errors}.", subsystem: :api)
        send_resp(conn, 500, "Failed to update state")
    end
  end

  post "/api/v1/task" do
    case ConvertTask.RepoInteraction.create_new_task(conn.assigns[:changeset]) do
      {:ok, saved_task} ->
        Conserva.TaskDistributor.add_to_queue(saved_task)
        Logger.info("Task #{saved_task.id} successful created", subsystem: :api)
        send_resp(conn, 200, "#{saved_task.id}")
      {:error, unsaved_task} ->
        Logger.error("Failed creating new task. Extended info: #{unsaved_task.errors}.", subsystem: :api)
        File.rm(conn.assigns[:potential_file_path])
        send_resp(conn, 422, "")
    end
  end

  delete "/api/v1/task/:id" do
    case ConvertTask.RepoInteraction.get_by_id(id) do
      :nil -> send_resp(conn, 404, "")
      task -> try_delete_task(conn, task)
    end
  end

  def try_delete_task(conn, task) do
    cond do
      task.state == "process" -> send_resp(conn, 423, "")
      true -> delete_task(conn, task)
    end
  end

  def delete_task(conn, task) do
    Logger.info("Start deleting task #{task.id}")
    case ConvertTask.RepoInteraction.delete(task) do
      {:ok, task} ->
        File.rm("#{Application.fetch_env!(:conserva, :file_storage_path)}/#{task.source_file}")
        File.rm("#{Application.fetch_env!(:conserva, :file_storage_path)}/#{task.converted_file}")
        Logger.info("Task #{task.id} successful deleted", subsystem: :api)
        send_resp(conn, 200, "")
      {:error, changeset} ->
        Logger.error("Failed deleting task #{task.id}. Extended info: #{changeset.errors}.", subsystem: :api)
        send_resp(conn, 500, "Error on deleting task")
    end
  end

  get "/api/v1/convert_combinations" do
    send_resp(conn, 200, Poison.encode!(GenServer.call(ConvertersInfoServer, :get_convert_combinations)))
  end

  get "/ping" do
    send_resp(conn, 200, "")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
