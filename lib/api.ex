defmodule TheTVDB.API do

  @moduledoc false

  @base_url Application.get_env(:thetvdb, :api_url)

  def get(endpoint, opts \\ []) do
    case request(:get, url(endpoint), opts) do
      {:ok, _, body} ->
        {:ok, body}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def head(endpoint, opts \\[]) do
    case request(:head, url(endpoint), opts) do
      {:ok, status_code, _} ->
        {:ok, status_code}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_stream(endpoint, opts \\ []) do
    start = fn ->
      case request(:get, url(endpoint), opts) do
        {:ok, _, body} ->
          %{"data" => data, "links" => links} = body
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
        case request(:get, url, opts) do
          {:ok, _, body} ->
            %{"data" => next_data, "links" => links} = body
            %{"next" => next} = links
            {data, {next_data, next}}
          {:error, reason} ->
            IO.puts("STREAM FAILED #{reason}")
            {data, nil}
        end
    end

    Stream.resource(start, next, fn _ -> nil end)
  end

  def put(endpoint, body \\ "", opts \\ []) do
    case request(:put, url(endpoint), body, opts) do
      {:ok, _, body} ->
        {:ok, body}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def post(endpoint, body, opts \\ []) do
    case request(:post, url(endpoint), body, opts) do
      {:ok, _, body} ->
        {:ok, body}
      {:error, reason} ->
        {:error, reason}
    end
  end
  
  def delete(endpoint, opts \\ []) do
    case request(:delete, url(endpoint), opts) do
      {:ok, _, _} ->
        :ok
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp headers(opts) do
    headers = [{"Content-Type", "application/json"}]

    if opts[:requires_auth] do
      Keyword.put(headers, :authorization, "Bearer #{opts[:token]}")
    else
      headers
    end
  end

  defp opts(opts) do
    opts = Keyword.put_new(opts, :requires_auth, true)
    opts = Keyword.put_new(opts, :scope, :global)

    if opts[:requires_auth] do
      Keyword.put_new_lazy(opts, :token, fn ->
        case TheTVDB.Auth.Registry.lookup(opts[:scope]) do
          pid when is_pid(pid) ->
            TheTVDB.Auth.Server.token(pid)
          nil ->
            throw :no_server_found
        end
      end)
    else
      opts
    end
  end

  def request(method, url, body \\ "", opts) do
    opts = opts(opts)
    headers = headers(opts)

    body = if is_binary(body), do: body, else: Poison.encode!(body)

    case HTTPoison.request(method, url, body, headers) do
      {:ok, %{status_code: code, body: body}} when byte_size(body) > 0 ->
        {:ok, code, Poison.decode!(body)}
      {:ok, %{status_code: code}} ->
        {:ok, code, nil}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp url(endpoint) do
    @base_url <> endpoint
  end
end
