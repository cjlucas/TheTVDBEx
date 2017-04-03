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

  @spec info(TheTVDB.Series.BasicEpisode.t | integer) :: t
  def info(%TheTVDB.Series.BasicEpisode{id: id}), do: info(id)
  def info(id) do
    case TheTVDB.API.get("/episodes/#{id}") do
      {:ok, %{"data" => data}} ->
        from_json(data)
      {:error, reason} ->
        {:error, reason}
    end
  end
end

