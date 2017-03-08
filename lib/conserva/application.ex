defmodule Conserva.Application do
  use Application
  use Supervisor


  def start(_type, _args) do
    children = [
          # Define workers and child supervisors to be supervised
          Plug.Adapters.Cowboy.child_spec(:http, Conserva.Router, [], [port: 4001]),
          worker(Conserva.TaskProcessor, [[:hello],[name: Conserva.TaskProcessor]])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Conserva.Application]
    Supervisor.start_link(children, opts)
  end
end