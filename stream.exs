IO.puts inspect Stream.resource(fn -> File.open!("tester.exs") end,
fn file ->
  {[1, 2, 3], file}
end,
fn file -> IO.puts("endfunc"); File.close(file) end)
|> Enum.to_list
