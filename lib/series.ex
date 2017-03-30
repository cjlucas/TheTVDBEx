
defmodule Test do
  use TheTVDB.Model

  @moduledoc """
  This struct does stuff
  """

  model do
    field "hi"
    field "There"
  end
end

defmodule Test2 do
  use TheTVDB.Model

  @moduledoc """
  This struct does stuff
  """

  model do
    field "hi"
    field "There"
  end
end

defmodule Thing do

  @doc """
  Documenting the struct
  """
  defstruct [:field1, :field2]
end
