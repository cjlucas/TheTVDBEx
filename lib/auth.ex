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
      {:error, reason} ->
        {:error, reason}
    end
  end

  #def refresh(token) do
  #end
end
