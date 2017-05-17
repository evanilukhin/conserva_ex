defmodule Conserva.ConverterServer do
  use GenServer
  require IEx
  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def handle_cast({:add_task, task}, state) do
    spawn(fn -> Conserva.TaskProcessor.convert(task, state[:converter]) end)
    {:noreply, state}
  end

  def handle_cast(:free_worker, state) do
    IO.inspect("I am free!")
    {:noreply, state}
  end

  defp launch_processor(task, converter) do

  end
end