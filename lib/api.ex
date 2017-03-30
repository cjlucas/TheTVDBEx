defmodule TheTVDB.API do
  @base_url "https://api.thetvdb.com"

  def get(endpoint, opts \\ []) do
    opts = Keyword.put_new(:requires_auth, true)



    url(endpoint) |> HTTPoison.get()
  end

  defp url(endpoint) do
    @base_url <> endpoint
  end
end
