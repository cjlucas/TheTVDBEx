defmodule TheTVDB do
  use Application
  @moduledoc """
  Documentation for Thetvdb.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Thetvdb.hello
      :world

  """
  def start(_, _) do
    import Supervisor.Spec, warn: false

    children = [
      registry(:unique, TheTVDB.Auth.Registry),
      supervisor(TheTVDB.Auth.Supervisor, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp registry(type, name) do
    import Supervisor.Spec, warn: false
    supervisor(Registry, [type, name], name: name)
  end

  @spec authenticate(binary) :: :ok | {:error, String.t}
  def authenticate(api_key) do
    {:ok, _} = TheTVDB.Auth.Supervisor.start_child(api_key)
    :ok
  end
  
  @spec authenticate(binary, String.t, binary) :: :ok | {:error, String.t}
  def authenticate(api_key, username, user_key) do
    {:ok, _} = TheTVDB.Auth.Supervisor.start_child(api_key, username, user_key)
    :ok
  end
end
