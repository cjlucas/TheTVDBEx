defmodule TheTVDB.NotAuthenticatedError do
  defexception [:message]
end

defmodule TheTVDB.NotFoundError do
  defexception [:message]
end

defmodule TheTVDB.ServerError do
  defexception reason: nil

  def message(%__MODULE__{reason: reason}), do: inspect(reason)
end
