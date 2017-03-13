defmodule Conserva.TaskProcessor.LibreOffice.Supervisor do
  use Supervisor

  def start_link(sup_options, options) do
    Supervisor.start_link(__MODULE__, sup_options, options)
  end

  def init(options) do
    children = for n <- 1..options[:count_workers], do: worker(Conserva.TaskProcessor.LibreOffice.Processor, [:ok], [id: n])
    supervise(children, strategy: :one_for_one)
  end
end
