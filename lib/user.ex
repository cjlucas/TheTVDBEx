defmodule TheTVDB.User do
  use TheTVDB.Model

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

  def info, do: do_info()
  def info(username) do
    scope(username) |> do_info
  end

  defp do_info(scope \\ :user) do
    case TheTVDB.API.get("/user", scope: scope) do
      {:ok, %{"data" => data}} ->
        from_json(data)
    end
  end
  
  def favorites, do: do_favorites()
  def favorites(username) do
    scope(username) |> do_favorites
  end

  def do_favorites(scope \\ :user) do
    case TheTVDB.API.get("/user/favorites", scope: scope) do
      {:ok, %{"data" => data}} ->
        data["favorites"]
    end
  end
  
  def add_favorite(series_id), do: do_add_favorite(series_id)
  def add_favorite(username, series_id) do
    scope(username) |> do_add_favorite(series_id)
  end

  defp do_add_favorite(scope \\ :user, series_id) do
    endpoint = "/user/favorites/#{series_id}"
    case TheTVDB.API.put(endpoint, "", scope: scope) do
      {:ok, _} ->
        :ok
    end
  end
  
  def remove_favorite(series_id), do: do_remove_favorite(series_id)
  def remove_favorite(username, series_id) do
    scope(username) |> do_remove_favorite(series_id)
  end

  defp do_remove_favorite(scope \\ :user, series_id) do
    endpoint = "/user/favorites/#{series_id}"
    TheTVDB.API.delete(endpoint, scope: scope)
  end

  def ratings, do: do_ratings()
  def ratings(username) do
    scope(username) |> do_ratings
  end

  def do_ratings(scope \\ :user) do
    TheTVDB.API.get_stream("/user/ratings", scope: scope)
    |> Stream.map(&Rating.from_json/1)
  end

  def add_rating(type, item, rating), do: do_add_rating(type, item, rating)
  def add_rating(username, type, item, rating) do
    scope(username) |> do_add_rating(type, item, rating)
  end

  defp do_add_rating(scope \\ :user, type, item, rating)
      when type in [:series, :episode, :image] and is_integer(rating) do
    type = Atom.to_string(type)
    endpoint = "/user/ratings/#{type}/#{item}/#{rating}"
    case TheTVDB.API.put(endpoint, "", scope: scope) do
      {:ok, _} ->
        :ok
    end
  end
  
  def remove_rating(type, item), do: do_remove_rating(type, item)
  def remove_rating(username, type, item) do
    scope(username) |> do_remove_rating(type, item)
  end

  defp do_remove_rating(scope \\ :user, type, item)
      when type in [:series, :episode, :image] do
    type = Atom.to_string(type)
    endpoint = "/user/ratings/#{type}/#{item}"
    TheTVDB.API.delete(endpoint, scope: scope)
  end

  defp scope(username) do
    {:user, username}
  end
end
