defmodule TheTVDB do
  use Application

  @doc false
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
    TheTVDB.Auth.Supervisor.start_child(api_key)
    |> handle_sup_response
  end
  
  @spec authenticate(binary, String.t, binary) :: :ok | {:error, String.t}
  def authenticate(api_key, username, user_key) do
    TheTVDB.Auth.Supervisor.start_child(api_key, username, user_key)
    |> handle_sup_response
  end

  defp handle_sup_response(resp) do
    case resp do
      {:ok, _}                        -> :ok
      {:error, {:already_started, _}} -> :ok
      {:error, {reason, _}}           -> {:error, reason}
    end 
  end
end
