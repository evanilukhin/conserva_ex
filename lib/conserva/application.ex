defmodule Conserva.Application do
  use Application


  def start(_type, _args) do
    children = [
          # Define workers and child supervisors to be supervised
          Plug.Adapters.Cowboy.child_spec(:http, Conserva.Router, [], [port: 4001])
        ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Conserva.Supervisor]
    Supervisor.start_link(children, opts)
  end
end