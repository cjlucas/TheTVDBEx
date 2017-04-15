defmodule TheTVDB.Auth.Registry do

  @moduledoc false

  @type scope :: :global | :user | {:user, binary}

  def start_link do
    Registry.start_link(:unique, __MODULE__)
  end

  @spec register(scope) :: :ok
  def register(scope) do
    case Registry.register(__MODULE__, scope, []) do
      {:ok, _}                           -> :ok
      {:error, {:already_registered, _}} -> :ok
      {:error, reason}                   -> {:error, reason}
    end
  end

  @spec lookup(scope) :: {:ok, binary} | {:error, :no_server_found}
  def lookup(scope) do
    case Registry.lookup(__MODULE__, scope) do
      [{pid, _}] ->
        pid
      [] ->
        nil
    end
  end
end
