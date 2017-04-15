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

      defstruct Module.get_attribute(__MODULE__, :model_fields) |> Enum.map(&Keyword.get(&1, :name))

      @type t :: %__MODULE__{}

      @doc false
      def from_json(data) when is_map(data) do
        Enum.reduce(@model_fields, %__MODULE__{}, fn metadata, acc ->
          name     = Keyword.get(metadata, :name)
          api_name = Keyword.get(metadata, :api_name)

          val = Map.get(data, api_name)
          val = case Keyword.get(metadata, :type) do
            :unix_timestamp ->
              TheTVDB.API.Utils.parse_unix_timestamp(val)
            :datetime ->
              TheTVDB.API.Utils.parse_datetime(val)
            :time ->
              TheTVDB.API.Utils.parse_time(val)
            :date ->
              TheTVDB.API.Utils.parse_date(val)
            :integer ->
              TheTVDB.API.Utils.parse_integer(val)
            nil ->
              val
          end

          Map.put(acc, name, val)
        end)
      end
    end
  end

  defmacro field(api_name, options \\ []) do
    name = api_name_to_snake_case(api_name)
    quote do
      metadata =
        unquote(options)
        |> Keyword.put(:name, unquote(name))
        |> Keyword.put(:api_name, unquote(api_name))

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
