defmodule TheTVDB.User do
  use TheTVDB.Model

  @rating_types [:series, :episode, :image]

  @type username :: String.t | nil

  @type rating_type :: :series | :episode | :image

  model do
    field "favoritesDisplaymode"
    field "language"
    field "userName"
  end

  defmodule Rating do
    use TheTVDB.Model

    model do
      field "rating"
      field "ratingItemId"
      field "ratingType"
    end
  end

  @spec info(username) :: t
  def info(username \\ nil) do
    case TheTVDB.API.get("/user", scope: scope(username)) do
      {:ok, %{"data" => data}} ->
        from_json(data)
    end
  end

  @spec favorites(username) :: [binary]
  def favorites(username \\ nil) do
    case TheTVDB.API.get("/user/favorites", scope: scope(username)) do
      {:ok, %{"data" => data}} ->
        data["favorites"]
    end
  end

  @spec add_favorite(username, integer) :: :ok
  def add_favorite(username \\ nil, series_id) do
    endpoint = "/user/favorites/#{series_id}"
    case TheTVDB.API.put(endpoint, "", scope: scope(username)) do
      {:ok, _} ->
        :ok
    end
  end

  @spec remove_favorite(username, integer) :: :ok
  def remove_favorite(username \\ nil, series_id) do
    endpoint = "/user/favorites/#{series_id}"
    TheTVDB.API.delete(endpoint, scope: scope(username))
  end

  @spec ratings(username) :: [Rating.t]
  def ratings(username \\ nil) do
    TheTVDB.API.get_stream("/user/ratings", scope: scope(username))
    |> Stream.map(&Rating.from_json/1)
  end

  @spec add_rating(username, rating_type, integer, integer) :: :ok
  def add_rating(username \\ nil, type, item, rating)
      when type in @rating_types and is_integer(rating) do
    type = Atom.to_string(type)
    endpoint = "/user/ratings/#{type}/#{item}/#{rating}"
    case TheTVDB.API.put(endpoint, "", scope: scope(username)) do
      {:ok, _} ->
        :ok
    end
  end

  @spec remove_rating(username, rating_type, integer) :: :ok
  def remove_rating(username \\ nil, type, item) when type in @rating_types do
    type = Atom.to_string(type)
    endpoint = "/user/ratings/#{type}/#{item}"
    TheTVDB.API.delete(endpoint, scope: scope(username))
  end

  defp scope(username) when is_nil(username), do: :user
  defp scope(username), do: {:user, username}
end
