defmodule TheTVDB.Auth do
  @moduledoc false

  def login(api_key) do
    do_login(%{"apikey" => api_key})
  end

  def login(api_key, username, user_key) do
    do_login(%{"apikey" => api_key, "username" => username, "userkey" => user_key})
  end

  defp do_login(body) do
    case TheTVDB.API.post("/login", body, requires_auth: false) do
      {:ok, %{"token" => token}} ->
        {:ok, token}
      {:ok, %{"Error" => _}} ->
        {:error, :unauthorized}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def refresh_token(token) do
    case TheTVDB.API.get("/refresh_token", token: token) do
      {:ok, %{"token" => token}} ->
        {:ok, token}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
