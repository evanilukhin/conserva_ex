defmodule Conserva.ConvertersServer do
  use GenServer

  def start_link(_state, opts \\ []) do
    converters = Conserva.ConvertersLoader.get_converters
    GenServer.start_link(__MODULE__, converters, opts)
  end

  # Client side
  def reload_converters do
    GenServer.cast(ConvertersServer, :reload_converters)
  end

  def get_converters do
    GenServer.call(ConvertersServer, :get_converters)
  end

  # Server side
  def handle_call(:get_converters, _from, converters) do
    {:reply, converters, converters}
  end

  def handle_cast(:reload_converters, _converters) do
    reloaded_converters = Conserva.ConvertersLoader.get_converters
    {:noreply, reloaded_converters}
  end
end
