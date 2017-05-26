defmodule Conserva.Application do
  use Application
  use Supervisor

  def start(_type, _args) do
    children = [
          supervisor(Conserva.Repo, []),
          worker(Conserva.ConvertersServer, [[name: ConvertersInfoServer]]),
          supervisor(Conserva.ConvertersSupervisor, [[]]),
          Plug.Adapters.Cowboy.child_spec(:http, Conserva.Router, [], [port: 4001])
    ]
    opts = [strategy: :one_for_one, name: Conserva.Application]
    Supervisor.start_link(children, opts)
  end
end
