defmodule ConservaTest.ApiTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "" do
    # Create a test connection
    conn = conn(:get, "/api/v1/task/1")

    # Invoke the plug
    conn = Conserva.Router.call(conn, [])

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "get task 1"
  end
end
