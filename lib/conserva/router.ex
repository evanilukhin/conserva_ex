defmodule Conserva.Router do
  use Plug.Router
  plug :match
  plug :dispatch

  get "/hello/:word" do
    GenServer.cast(TaskProcessor, {:push, word})
    send_resp(conn, 200, "world")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end