defmodule TheTVDB.Auth.Supervisor do
  use Supervisor

  @moduledoc false

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    supervise([], strategy: :one_for_one)
  end

  def start_child(api_key) do
    child = worker(TheTVDB.Auth.Server, [api_key], id: :global, restart: :transient)
    Supervisor.start_child(__MODULE__, child)
  end

  def start_child(api_key, username, user_key) do
    if Registry.lookup(TheTVDB.Auth.Registry, :global) |> Enum.empty? do
      case start_child(api_key) do
        {:ok, _}         -> :ok
        {:error, reason} -> {:error, reason}
      end
    end

    child = worker(TheTVDB.Auth.Server, [api_key, username, user_key], id: {:user, username}, restart: :transient)
    Supervisor.start_child(__MODULE__, child)
  end
end
