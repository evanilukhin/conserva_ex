defmodule Conserva.TaskProcessor.ImageMagic.Processor do
  use GenServer
  require Integer

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(:ok) do
    {:ok, "I`m started"}
  end

  def handle_call({:process, options}, _from, []) do
    {:reply, process_task(), []}
  end

  defp process_task do
    if Integer.is_odd(:rand.uniform(2)) do
      {:ok, "Succesful convert"}
    else
      {:error, "Ooops..."}
    end
  end
end
