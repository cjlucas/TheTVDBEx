defmodule TheTVDB.Auth.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, __MODULE__)
  end

  def init(:ok) do
    supervise([], strategy: :one_for_one)
  end

  def start_child(api_key) do
    child = worker(TheTVDB.Auth.Server, [api_key], id: :global, restart: :transient)
    Supervisor.start_child(__MODULE__, child)
  end
  
  def start_child(api_key, username, user_key) do
    if Registry.lookup(Registry, :global) |> Enum.empty? do
      {:ok, _} = start_child(api_key)
    end

    child = worker(TheTVDB.Auth.Server, [api_key, username, user_key], id: {:user, username}, restart: :transient)
    Supervisor.start_child(__MODULE__, child)
  end
end
