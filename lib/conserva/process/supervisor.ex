defmodule Conserva.ConvertersSupervisor do
  use Supervisor

  def start_link(options) do
    Supervisor.start_link(__MODULE__,[], options)
  end

  def init(_options) do
    supervise(childrens(), strategy: :one_for_one)
  end

  defp childrens do
    converters = GenServer.call(ConvertersInfoServer, :get_converters)
    for converter <- converters do
      worker(Conserva.ConverterServer, [%{converter: converter}, [name: converter.name]],
                                       [id: converter.name])
    end
  end
end
