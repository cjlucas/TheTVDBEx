defmodule TheTVDB.Series do
  use TheTVDB.Model

  import TheTVDB.API.Utils, only: [unwrap_or_raise: 1]

  model do
    field "airsDayOfWeek"
    field "airsTime", type: :time
    field "aliases"
    field "banner"
    field "firstAired", type: :date
    field "genre"
    field "id"
    field "imdbId"
    field "lastUpdated", type: :unix_timestamp
    field "network"
    field "networkId"
    field "overview"
    field "rating"
    field "runtime", type: :integer
    field "seriesId"
    field "seriesName"
    field "siteRating"
    field "siteRatingCount"
    field "status"
    field "zap2itId"
  end

  defmodule Actor do
    use TheTVDB.Model

    model do
     field "id"
     field "image"
     field "imageAdded", type: :datetime
     field "imageAuthor"
     field "lastUpdated", type: :datetime
     field "name"
     field "role"
     field "seriesId"
     field "sortOrder"
    end
  end

  defmodule BasicEpisode do
    use TheTVDB.Model

    model do
      field "absoluteNumber"
      field "airedEpisodeNumber"
      field "airedSeason"
      field "dvdEpisodeNumber"
      field "dvdSeason"
      field "episodeName"
      field "firstAired", type: :date
      field "id"
      field "lastUpdated", type: :unix_timestamp
      field "overview"
    end
  end

  defmodule SearchResult do
    use TheTVDB.Model

    model do
      field "aliases"
      field "banner"
      field "firstAired", type: :date
      field "id"
      field "network"
      field "overview"
      field "seriesName"
      field "status"
    end
  end

  @doc """
  Determine if a given series exists.
  """
  @spec exists?(integer) :: {:ok, boolean} | {:error, term}
  def exists?(id) do
    case TheTVDB.API.head("/series/#{id}") do
      {:ok, _} ->
        {:ok, true}
      {:error, %TheTVDB.NotFoundError{}} ->
        {:ok, false}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  See `exists?/1`.
  """
  @spec exists!(integer) :: boolean
  def exists!(id), do: exists?(id) |> unwrap_or_raise

  @doc """
  Get info about a series.
  """
  @spec info(integer) :: {:ok, t} | {:error, term}
  def info(id) do
    case TheTVDB.API.get("/series/#{id}") do
      {:ok, %{"data" => data}} ->
        {:ok, from_json(data)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  See `info/1`.
  """
  @spec info!(integer) :: t
  def info!(id), do: info(id) |> unwrap_or_raise

  @doc """
  Get all actors for a given series.
  """
  @spec actors(integer) :: {:ok, [Actor.t]} | {:error, term}
  def actors(series_id) do
    case TheTVDB.API.get("/series/#{series_id}/actors") do
      # API WORKAROUND: This endpoint returns {data: nil} if an
      # invalid series_id is given, so just throw NotFoundError as if
      # the endpoint return a 404 (as it should)
      {:ok, %{"data" => data}} when is_nil(data)->
        {:error, TheTVDB.NotFoundError.exception("ID #{series_id} not found")}
      {:ok, %{"data" => data}} ->
        {:ok, data |> Enum.map(&Actor.from_json(&1))}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  See `actors/1`.
  """
  @spec actors!(integer) :: [Actor.t]
  def actors!(series_id), do: actors(series_id) |> unwrap_or_raise

  @doc """
  Get all episodes for a given series.

  An `Enumerable` of `TheTVDB.Series.BasicEpisode` is returned.
  """
  @spec episodes(integer) :: {:ok, Enumerable.t} | {:error, term}
  def episodes(series_id) do
    case TheTVDB.API.get_iter("/series/#{series_id}/episodes") do
      {:ok, data} ->
        {:ok, Enum.map(data, &BasicEpisode.from_json/1)}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  See `episodes/1`.
  """
  @spec episodes!(integer) :: Enumerable.t
  def episodes!(series_id), do: episodes(series_id) |> unwrap_or_raise

  @doc """
  Search for a series by name.

  An `Enumerable` of `TheTVDB.Series.SearchResult` is returned.
  """
  @spec search_by_name(String.t) :: {:ok, Enumerable.t} | {:error, term}
  def search_by_name(name) do
    search_by("name", name)
  end

  @doc """
  See `search_by_name/1`.
  """
  @spec search_by_name!(String.t) :: Enumerable.t
  def search_by_name!(name), do: search_by_name(name) |> unwrap_or_raise

  @doc """
  Search for a series by IMDb ID.

  An `Enumerable` of `TheTVDB.Series.SearchResult` is returned.
  """
  @spec search_by_imdb_id(binary | integer) :: {:ok, Enumerable.t} | {:error, term}
  def search_by_imdb_id(id) do
    search_by("imdbId", id)
  end

  @doc """
  See `search_by_imdb_id/1`.
  """
  @spec search_by_imdb_id!(binary | integer) :: Enumerable.t
  def search_by_imdb_id!(id), do: search_by_imdb_id(id) |> unwrap_or_raise

  @doc """
  Search for a series by Zap2It ID.

  An `Enumerable` of `TheTVDB.Series.SearchResult` is returned.
  """
  @spec search_by_zap2it_id(binary | integer) :: {:ok, Enumerable.t} | {:error, term}
  def search_by_zap2it_id(id) do
    search_by("zap2itId", id)
  end

  @doc """
  See `search_by_zap2it_id/1`.
  """
  @spec search_by_zap2it_id!(binary | integer) :: Enumerable.t
  def search_by_zap2it_id!(id), do: search_by_zap2it_id(id) |> unwrap_or_raise

  defp search_by(param, query) do
    endpoint = "/search/series?#{URI.encode_query(%{param => query})}"
    IO.puts endpoint
    case TheTVDB.API.get(endpoint) do
      {:ok, %{"data" => data}} ->
        {:ok, data |> Enum.map(&SearchResult.from_json(&1))}
      # API WORKAROUND: A 404 is returned if no results are found.
      # But it's more natural to return an empty list indicating no results.
      {:error, %TheTVDB.NotFoundError{}} ->
        {:ok, []}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
