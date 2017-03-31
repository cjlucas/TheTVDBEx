defmodule TheTVDB.Model do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import TheTVDB.Model
    end
  end

  defmacro model(block) do
    quote do
      Module.register_attribute(__MODULE__, :model_fields, accumulate: true, persist: false)
      unquote(block)

      defstruct (Module.get_attribute(__MODULE__, :model_fields) |> Enum.map(&elem(&1, 0)))

      @doc false
      def from_json(data) when is_map(data) do
        @model_fields
        |> Enum.reduce(%__MODULE__{}, fn {name, api_name}, acc ->
          val = Map.get(data, api_name)
          Map.put(acc, name, val)
        end)
      end
    end
  end

  defmacro field(api_name) do
    name = api_name_to_snake_case(api_name)
    quote do
      metadata = {unquote(name), unquote(api_name)}
      Module.put_attribute(__MODULE__, :model_fields, metadata)
    end
  end

  defp api_name_to_snake_case(name) do
    name
    |> String.to_charlist
    |> Enum.reduce([], fn c, acc ->
      if c >= 65 && c <= 90 do
        [[c + 32, ?_] | acc]
      else
        [c | acc]
      end
    end)
    |> String.Chars.to_string
    |> String.reverse
    |> String.to_atom
  end
end
