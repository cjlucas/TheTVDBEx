defmodule TheTVDB.API do

  @moduledoc false

  @base_url Application.get_env(:thetvdb, :api_url, "https://api.thetvdb.com")

  @max_attempts Application.get_env(:thetvdb, :max_attempts, 5)

  @backoff_multiplier Application.get_env(:thetvdb, :backoff_multiplier, 300)

  def get(endpoint, opts \\ []) do
    case request(:get, url(endpoint), opts) do
      {:ok, _, body} ->
        {:ok, body}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_iter(endpoint, opts \\ []) do
    get_iter(endpoint, [], opts)
  end
  defp get_iter(endpoint, acc, opts) do
    case get(endpoint, opts) do
      {:ok, %{"data" => data, "links" => %{"next" => nil}}} ->
        {:ok, Enum.reverse([data | acc]) |> List.flatten}
      {:ok, %{"data" => data, "links" => %{"next" => page}}} ->
        opts = Keyword.put(opts, :page, page)
        get_iter(endpoint, [data | acc], opts)
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
    opts = Keyword.put_new(opts, :page, 0)

    if opts[:requires_auth] do
      Keyword.put_new_lazy(opts, :token, fn ->
        case TheTVDB.Auth.Registry.lookup(opts[:scope]) do
          pid when is_pid(pid) ->
            TheTVDB.Auth.Server.token(pid)
          nil ->
            # NOTE(cjlucas): This raise is intentional as this only
            # occurs if the user did not authenticate for the given scope
            raise TheTVDB.NotAuthenticatedError, "No token found (scope: #{inspect opts[:scope]})"
        end
      end)
    else
      opts
    end
  end

  def request(method, url, body \\ "", opts) do
    use Bitwise

    opts = opts(opts)
    headers = headers(opts)

    url =
      if opts[:page] > 0 do
        query =
          URI.parse(url).query || %{}
          |> Map.put("page", opts[:page])
          |> URI.encode_query

        url
        |> URI.parse
        |> Map.put(:query, query)
        |> URI.to_string
      else
        url
      end

    body = if is_binary(body), do: body, else: Poison.encode!(body)

    case HTTPoison.request(method, url, body, headers) do
      {:ok, %{status_code: 401}} ->
        {:error, %TheTVDB.NotAuthenticatedError{message: "Not authenticated"}}
      {:ok, %{status_code: 404, body: body}} ->
        msg = decode!(body) |> Map.get("Error")
        {:error, %TheTVDB.NotFoundError{message: msg}}
      {:ok, %{status_code: code, body: body}} when byte_size(body) > 0 ->
        {:ok, code, decode!(body)}
      {:ok, %{status_code: code}} ->
        {:ok, code, nil}
      {:error, %HTTPoison.Error{reason: reason}} ->
        opts = Keyword.update(opts, :num_attempts, 1, &(&1 + 1))
        if opts[:num_attempts] == @max_attempts do
          {:error, %TheTVDB.ServerError{reason: reason}}
        else
          delay = (2 <<< (opts[:num_attempts] - 1)) * @backoff_multiplier
          Process.sleep(delay)
          request(method, url, body, opts)
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp decode!(""), do: %{}
  defp decode!(body), do: Poison.decode!(body)

  defp url(endpoint) do
    @base_url <> endpoint
  end
end
