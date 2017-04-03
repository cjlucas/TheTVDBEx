defmodule TheTVDB.Auth.Registry do

  @moduledoc false

  @type scope :: :global | :user | {:user, binary}

  def start_link do
    Registry.start_link(:unique, __MODULE__)
  end

  @spec register(scope) :: :ok
  def register(scope) do
    :ok = Registry.unregister(__MODULE__, scope)
    {:ok, _} = Registry.register(__MODULE__, scope, [])
    :ok
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
