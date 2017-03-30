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
      supervisor(Registry, [:unique, Registry])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
