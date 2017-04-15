defmodule TheTVDB.NotAuthenticatedError do
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule TheTVDB.NotFoundError do
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end
