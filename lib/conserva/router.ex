defmodule Conserva.Router do
  use Plug.Router
  plug :match
  plug :dispatch

  get "/api/v1/task/:id" do
    send_resp(conn, 200, "get task #{id}")
  end

  get "/api/v1/async_convert" do
    send_resp(conn, 200, "async_convert")
  end

  post "/api/v1/task" do
    send_resp(conn, 200, "post task")
  end

  delete "/api/v1/task/:id" do
    send_resp(conn, 200, "delete task #{id}") 
  end

  get "/api/v1/convert_combinations" do
    send_resp(conn, 200, "convert_combinations")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
