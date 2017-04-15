defmodule TheTVDB.API.Utils do
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

  def parse_date(date) do
    Timex.parse!(date, "%Y-%m-%d", :strftime) |> NaiveDateTime.to_date
  end
end
