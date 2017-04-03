defmodule TheTVDB.Series do
  use TheTVDB.Model

  model do
    field "airsDayOfWeek"
    field "airsTime"
    field "aliases"
    field "banner"
    field "firstAired"
    field "genre"
    field "id"
    field "imdbId"
    field "lastUpdated"
    field "network"
    field "networkId"
    field "overview"
    field "rating"
    field "runtime"
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
     field "imageAdded"
     field "imageAuthor"
     field "lastUpdated"
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
      field "firstAired"
      field "id"
      field "lastUpdated"
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

  @spec exists?(integer) :: boolean
  def exists?(id) do
    case TheTVDB.API.head("/series/#{id}") do
      {:ok, code} ->
        code == 200
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec info(integer) :: t
  def info(id) do
    case TheTVDB.API.get("/series/#{id}") do
      {:ok, %{"data" => data}} ->
        from_json(data)
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec actors(integer) :: [Actor.t]
  def actors(series_id) do
    case TheTVDB.API.get("/series/#{series_id}/actors") do
      {:ok, %{"data" => data}} ->
        data |> Enum.map(&Actor.from_json(&1))
      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec episodes(integer) :: [BasicEpisode.t]
  def episodes(series_id) do
    TheTVDB.API.get_stream("/series/#{series_id}/episodes")
    |> Stream.map(&BasicEpisode.from_json/1)
  end

  @spec search_by_name(String.t) :: [t]
  def search_by_name(name) do
    search_by("name", name)
  end

  @spec search_by_imdb_id(binary | integer) :: [t]
  def search_by_imdb_id(id) do
    search_by("imdbId", id)
  end

  @spec search_by_zap2it_id(binary | integer) :: [t]
  def search_by_zap2it_id(id) do
    search_by("zap2itId", id)
  end

  defp search_by(param, query) do
    endpoint = "/search/series?#{URI.encode_query(%{param => query})}"
    IO.puts endpoint
    case TheTVDB.API.get(endpoint) do
      {:ok, %{"data" => data}} ->
        data |> Enum.map(&SeriesSearch.from_json(&1))
      {:error, reason} ->
        {:error, reason}
    end
  end
end
