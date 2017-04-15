defmodule TheTVDB.Series do
  use TheTVDB.Model

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

  defmodule SeriesSearch do
    use TheTVDB.Model

    model do
      field "aliases"
      field "banner"
      field "firstAired"
      field "id"
      field "network"
      field "overview"
      field "seriesName"
      field "status"
    end
  end

  @doc "Determine if a given series exists."
  @spec exists?(integer) :: boolean
  def exists?(id) do
    case TheTVDB.API.head("/series/#{id}") do
      {:ok, code} ->
        code == 200
      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Get info about a series.
  """
  @spec info(integer) :: t
  def info(id) do
    case TheTVDB.API.get("/series/#{id}") do
      {:ok, %{"data" => data}} ->
        from_json(data)
      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Get all actors for a given series.
  """
  @spec actors(integer) :: [Actor.t]
  def actors(series_id) do
    case TheTVDB.API.get("/series/#{series_id}/actors") do
      # API WORKAROUND: This endpoint returns {data: nil} if an
      # invalid series_id is given, so just throw NotFoundError as if
      # the endpoint return a 404 (as it should)
      {:ok, %{"data" => data}} when is_nil(data)->
        raise TheTVDB.NotFoundError, "ID #{series_id} not found"
      {:ok, %{"data" => data}} ->
        data |> Enum.map(&Actor.from_json(&1))
      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Get all episodes for a given series.
  
  An `Enumerable` of `TheTVDB.Series.BasicEpisode` is returned.
  """
  @spec episodes(integer) :: Enumerable.t
  def episodes(series_id) do
    TheTVDB.API.get_stream("/series/#{series_id}/episodes")
    |> Stream.map(&BasicEpisode.from_json/1)
  end

  @doc """
  Search for a series by name.
  
  An `Enumerable` of `TheTVDB.Series.SeriesSearch` is returned.
  """
  @spec search_by_name(String.t) :: Enumerable.t
  def search_by_name(name) do
    search_by("name", name)
  end

  @doc """
  Search for a series by name.
  
  An `Enumerable` of `TheTVDB.Series.SeriesSearch` is returned.
  """
  @spec search_by_imdb_id(binary | integer) :: Enumerable.t
  def search_by_imdb_id(id) do
    search_by("imdbId", id)
  end

  @doc """
  Search for a series by name.
  
  An `Enumerable` of `TheTVDB.Series.SeriesSearch` is returned.
  """
  @spec search_by_zap2it_id(binary | integer) :: Enumerable.t
  def search_by_zap2it_id(id) do
    search_by("zap2itId", id)
  end

  defp search_by(param, query) do
    endpoint = "/search/series?#{URI.encode_query(%{param => query})}"
    IO.puts endpoint
    case TheTVDB.API.get(endpoint) do
      {:ok, %{"data" => data}} ->
        data |> Enum.map(&SeriesSearch.from_json(&1))
      # API WORKAROUND: A 404 is returned if no results are found.
      # But it's more natural to return an empty list indicating no results.
      {:error, %TheTVDB.NotFoundError{}} ->
        []
      {:error, reason} ->
        raise reason
    end
  end
end
