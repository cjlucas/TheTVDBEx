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
    field "firstAired", type: :date
    field "guestStars"
    field "id"
    field "imdbId"
    field "lastUpdated", type: :unix_timestamp
    field "lastUpdatedBy"
    field "overview"
    field "productionCode"
    field "seriesId"
    field "showUrl"
    field "siteRating"
    field "siteRatingCount"
    field "thumbAdded"
    field "thumbAuthor"
    field "thumbHeight", type: :integer
    field "thumbWidth", type: :integer
    field "writers"
  end

  @doc """
  Get info about an episode.
  """
  @spec info(TheTVDB.Series.BasicEpisode.t | integer) :: t
  def info(%TheTVDB.Series.BasicEpisode{id: id}), do: info(id)
  def info(id) do
    case TheTVDB.API.get("/episodes/#{id}") do
      {:ok, %{"data" => data}} ->
        from_json(data)
      {:error, reason} ->
        raise reason
    end
  end
end

