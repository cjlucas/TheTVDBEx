defmodule TheTVDB.Auth.Server do
  use GenServer
  
  @moduledoc false

  defmodule State do
    @moduledoc false

    defstruct [:token, :expires_in]
  end

  def start_link(api_key) do
    GenServer.start_link(__MODULE__, {:global, api_key}, name: via(:global))
  end
  
  def start_link(api_key, username, user_key) do
    GenServer.start_link(__MODULE__, {:user, api_key, username, user_key}, name: via({:user, username}))
  end

  def init({:global, api_key}) do
    case TheTVDB.Auth.login(api_key) do
      {:ok, token} ->
        {:ok, %State{token: token}}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  #def init({:user, api_key, username, user_key}) do
  #end


  def token(:global) do
    via(:global) |> GenServer.call(:token)
  end

  def token({:user, username}) do
    via({:user, username}) |> GenServer.call(:token)
  end

  def handle_call(:token, _from, state) do
    %{token: token} = state
    {:reply, token, state} 
  end

  defp via(key) do
    {:via, Registry, {Registry, key}}
  end
end
