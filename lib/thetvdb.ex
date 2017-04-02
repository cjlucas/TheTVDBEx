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
      supervisor(Registry, [:unique, Registry]),
      supervisor(TheTVDB.Auth.Supervisor, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @spec authenticate(binary) :: :ok | {:error, String.t}
  def authenticate(api_key) do
    {:ok, _} = TheTVDB.Auth.Supervisor.start_child(api_key)
    :ok
  end
end
