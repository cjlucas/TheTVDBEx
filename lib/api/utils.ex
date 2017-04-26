defmodule TheTVDB.API.Utils do
  def parse_time(""), do: nil
  def parse_time(time) when is_nil(time), do: nil
  def parse_time(time) do
    formats = ["%l:%M %p", "%H:%M", "%k:%M"]
    parse_time(time, formats)
  end

  defp parse_time(_time, []), do: ~T[00:00:00]
  defp parse_time(time, [fmt | rest]) do
    case Timex.parse(time, fmt, :strftime) do
      {:ok, t}    ->
        NaiveDateTime.to_time(t)
      {:error, _} ->
        parse_time(time, rest)
    end
  end

  def parse_date(""), do: nil
  def parse_date(date) when is_nil(date), do: nil
  def parse_date(date) do
    Timex.parse!(date, "%Y-%m-%d", :strftime) |> NaiveDateTime.to_date
  end

  def parse_datetime(""), do: nil
  def parse_datetime(date) when is_nil(date), do: nil
  def parse_datetime(date) do
    Timex.parse!(date, "%Y-%m-%d %H:%M:%S", :strftime)
  end

  def parse_integer(""), do: nil
  def parse_integer(int) when is_nil(int), do: nil
  def parse_integer(int) when is_integer(int), do: int
  def parse_integer(int) when is_binary(int), do: String.to_integer(int)

  def parse_unix_timestamp(""), do: nil
  def parse_unix_timestamp(time) when is_nil(time), do: nil
  def parse_unix_timestamp(time) when is_integer(time), do: Timex.from_unix(time)
  def parse_unix_timestamp(time) when is_binary(time) do
    String.to_integer(time) |> parse_unix_timestamp
  end

  def unwrap_or_raise(:ok), do: :ok
  def unwrap_or_raise({:ok, data}), do: data
  def unwrap_or_raise({:error, reason}), do: raise reason
end
