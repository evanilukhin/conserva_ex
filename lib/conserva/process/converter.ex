defmodule Conserva.Converter do
  defstruct name: 1,
            max_workers_count: 1,
            from_ext: [],
            to_ext: [],
            launch_string: ""

  def new(params) when is_map(params) do
    struct(Conserva.Converter, prepared_params(params))
  end

  defp prepared_params(params) do
    atomize_keys(params) |> atomize_name
  end

  defp atomize_keys(params) do
    Enum.reduce(params, %{}, fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end)
  end

  defp atomize_name(params) do
    Map.update!(params, :name, fn(value) -> String.to_atom(value) end)
  end
end
