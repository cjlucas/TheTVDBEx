defmodule TheTVDB.API do

  @base_url Application.get_env(:thetvdb, :api_url)

  def get(endpoint, opts \\ []) do
    opts = Keyword.put_new(opts, :requires_auth, true)
    headers = headers(opts)

    case url(endpoint) |> HTTPoison.get(headers) do
      {:ok, %{body: body}} ->
        Poison.decode(body)
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_stream(endpoint, opts \\ []) do
    opts = Keyword.put_new(opts, :requires_auth, true)

    start = fn ->
      IO.puts(url(endpoint))
      case HTTPoison.get(url(endpoint), headers(opts)) do
        {:ok, %{body: body}} ->
          %{"data" => data, "links" => links} = Poison.decode!(body)
          %{"next" => next} = links
          {data, next}
        {:error, reason} ->
          IO.puts("STREAM FAILED #{reason}")
          {[], nil}
      end
    end

    next = fn
      {[], nil} = acc ->
        {:halt, acc}
      {data, nil} ->
        {data, {[], nil}}
      {data, page} ->
        query =
          URI.parse(endpoint).query || %{}
          |> Map.put("page", page)
          |> URI.encode_query

        url =
          url(endpoint)
          |> URI.parse
          |> Map.put(:query, query)
          |> URI.to_string

        IO.puts(url)
        case HTTPoison.get(url, headers(opts)) do
          {:ok, %{body: body}} ->
            %{"data" => next_data, "links" => links} = Poison.decode!(body)
            %{"next" => next} = links
            {data, {next_data, next}}
          {:error, reason} ->
            IO.puts("STREAM FAILED #{reason}")
            {data, nil}
        end
    end

    Stream.resource(start, next, fn _ -> nil end)
  end

  def post(endpoint, body, opts \\ []) do
    opts = Keyword.put_new(opts, :requires_auth, true)
    headers = headers(opts)

    case url(endpoint) |> HTTPoison.post(Poison.encode!(body), headers) do
      {:ok, %{body: body}} ->
        Poison.decode(body)
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp headers(opts) do
    headers = [{"Content-Type", "application/json"}]

    if opts[:requires_auth] do
      Keyword.put(headers, :authorization, "Bearer #{token()}")
    else
      headers
    end
  end

  defp url(endpoint) do
    @base_url <> endpoint
  end

  defp token do
    TheTVDB.Auth.Server.token(:global)
  end
end
