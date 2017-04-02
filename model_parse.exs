IO.binstream(:stdio, :line)
|> Enum.map(fn l -> String.split(l) |> List.first end)
|> Enum.each(fn s -> IO.puts("field \"#{s}\"") end)
