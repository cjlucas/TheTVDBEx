defmodule TheTVDB.Auth.Server do
  use GenServer

  @moduledoc false

  @refresh_interval 60 * 60 * 1000

  defmodule State do
    @moduledoc false

    defstruct [:token, :expires_at]
  end

  def start_link(api_key) do
    GenServer.start_link(__MODULE__, {:global, api_key})
  end

  def start_link(api_key, username, user_key) do
    GenServer.start_link(__MODULE__, {:user, api_key, username, user_key})
  end

  def init({:global, api_key}) do
    TheTVDB.Auth.Registry.register(:global)

    case TheTVDB.Auth.login(api_key) do
      {:ok, token} ->
        expires_at = now() + @refresh_interval
        {:ok, %State{token: token, expires_at: expires_at}, @refresh_interval}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  def init({:user, api_key, username, user_key}) do
    TheTVDB.Auth.Registry.register(:user)
    TheTVDB.Auth.Registry.register({:user, username})

    case TheTVDB.Auth.login(api_key, username, user_key) do
      {:ok, token} ->
        expires_at = now() + @refresh_interval
        {:ok, %State{token: token, expires_at: expires_at}, @refresh_interval}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  @spec refresh(pid) :: :ok | {:error, String.t}
  def refresh(pid) do
    GenServer.call(pid, :refresh)
  end

  @spec token(pid) :: String.t
  def token(pid) do
    GenServer.call(pid, :token)
  end

  def handle_call(:refresh, _from, state) do
    %{token: token} = state

    {reply, token} =
      case TheTVDB.Auth.refresh_token(token) do
        {:ok, t}         -> {:ok, t}
        {:error, reason} -> {{:error, reason}, token}
      end

    expires_at = now() + @refresh_interval
    {:reply, reply, %{state | token: token, expires_at: expires_at}, @refresh_interval}
  end

  def handle_call(:token, _from, state) do
    %{token: token, expires_at: expires_at} = state
    {:reply, token, state, timeout(expires_at)}
  end

  def handle_info(:timeout, state) do
    {:reply, _, state, timeout} = handle_call(:refresh, nil, state)
    {:noreply, state, timeout}
  end

  defp timeout(expires_at) do
    expires_at - now()
  end

  defp now do
    System.monotonic_time(:millisecond)
  end
end
