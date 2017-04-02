IO.binstream(:stdio, :line)
|> Enum.each(fn l -> IO.puts l end)
