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
  end

  def init({:user, api_key, username, user_key}) do
  end


  def token(:global) do
    
  end

  def token({:user, username}) do
  end

  def handle_call(:token, _from, state) do
    %{token: token} = state
    {:reply, token, state} 
  end

  defp via(key) do
    {:via, Registry, {Registry, key}}
  end
end
