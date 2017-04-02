
defmodule Test do
  use TheTVDB.Model

  @moduledoc """
  This struct does stuff
  """

  model do
    field "hi"
    field "There"
  end
end

defmodule Test2 do
  use TheTVDB.Model

  @moduledoc """
  This struct does stuff
  """

  model do
    field "hi"
    field "There"
  end
end

defmodule Thing do

  @doc """
  Documenting the struct
  """
  defstruct [:field1, :field2]
end

defmodule TheTVDB.Episode do
  use TheTVDB.Model

  model do
    field "absoluteNumber"
    field "airedEpisodeNumber"
    field "airedSeason"
    field "airsAfterSeason"
    field "airsBeforeEpisode"
    field "airsBeforeSeason"
    field "director"
    field "directors"
    field "dvdChapter"
    field "dvdDiscid"
    field "dvdEpisodeNumber"
    field "dvdSeason"
    field "episodeName"
    field "filename"
    field "firstAired"
    field "guestStars"
    field "id"
    field "imdbId"
    field "lastUpdated"
    field "lastUpdatedBy"
    field "overview"
    field "productionCode"
    field "seriesId"
    field "showUrl"
    field "siteRating"
    field "siteRatingCount"
    field "thumbAdded"
    field "thumbAuthor"
    field "thumbHeight"
    field "thumbWidth"
    field "writers"
  end
end

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

  defmodule Actors do
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

    def get(series_id) do
      case TheTVDB.API.get("/series/#{series_id}/actors") do
        {:ok, %{"data" => data}} ->
          data |> Enum.map(&from_json(&1))
        {:error, reason} ->
          {:error, reason}
      end
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

  def get(id) do
    case TheTVDB.API.get("/series/#{id}") do
      {:ok, %{"data" => data}} ->
        from_json(data)
      {:error, reason} ->
        {:error, reason}
    end
  end

  def episodes(series_id) do
    TheTVDB.API.get_stream("/series/#{series_id}/episodes")
    |> Stream.map(&BasicEpisode.from_json/1)
  end
end
