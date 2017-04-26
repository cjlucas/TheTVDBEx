defmodule TheTVDB do
  use Application

  @moduledoc """
  This module provides access to TheTVDB API.


  ## Authentication

  This module supports multiple ways to authenticate with TheTVDB API.

  If only interested in globally-scoped endpoints (such as fetching
  series/episode information), Authenticating via `TheTVDB.authenticate/1`
  is all that's required.

  Token refreshes are handled automatically by the library.

  ### User Authentication

  This module supports multi-user authentication. All functions in `TheTVDB.User`
  support an optional username. If the username is omitted, the last
  authenticated user will be used.

  It is recommended that if multiple users have been authenticated, the
  username should be specified.

      TheTVDB.authenticate(api_key, "johnDoe", acct_id)
      # => :ok

      # Fetch user authentication for johnDoe
      TheTVDB.User.info()

      TheTVDB.authenticate(api_key, "jamesDean", acct_id)

      # Fetch user authentication for jamesDean
      TheTVDB.User.info("jamesDean")
  """

  import TheTVDB.API.Utils, only: [unwrap_or_raise: 1]

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

  @doc """
  Authenticate with TheTVDB API. This will provide access to globally
  scoped endpoints.
  """
  @spec authenticate(binary) :: :ok | {:error, TheTVDB.NotAuthenticatedError.t}
  def authenticate(api_key) do
    TheTVDB.Auth.Supervisor.start_child(api_key)
    |> handle_sup_response
  end

  @doc """
  See `authenticate/1`.
  """
  @spec authenticate!(binary) :: :ok
  def authenticate!(api_key), do: authenticate(api_key) |> unwrap_or_raise

  @doc """
  Authenticate with TheTVDB API. This will provide access to both globally
  and user scoped endpoints.

  Note: `user_key` corresponds to the "Account Identifier" under the
  user account page.
  """
  @spec authenticate(binary, String.t, binary) :: :ok | {:error, TheTVDB.NotAuthenticatedError.t}
  def authenticate(api_key, username, user_key) do
    TheTVDB.Auth.Supervisor.start_child(api_key, username, user_key)
    |> handle_sup_response
  end

  @doc """
  See `authenticate/3`.
  """
  @spec authenticate!(binary, String.t, binary) :: :ok
  def authenticate!(api_key, username, user_key) do
    authenticate(api_key, username, user_key) |> unwrap_or_raise
  end

  defp handle_sup_response(resp) do
    case resp do
      {:ok, _}                        -> :ok
      {:error, {:already_started, _}} -> :ok
      {:error, {reason, _}}           -> {:error, reason}
    end
  end
end
