defmodule TheTVDB.User do
  use TheTVDB.Model

  @moduledoc """
  This module contains access to all user-scoped endpoints.

  All functions allow the user to specify an optional username. If no
  username is specified, the last authenticated user will be used. See
  `TheTVDB` for more information.
  """

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

  @doc """
  Get info about a user.
  """
  @spec info(username) :: t
  def info(username \\ nil) do
    case TheTVDB.API.get("/user", scope: scope(username)) do
      {:ok, %{"data" => data}} ->
        from_json(data)
      {:error, reason} ->
          raise reason
    end
  end

  @doc """
  Get a list of all favorited series for a given user.
  """
  @spec favorites(username) :: [binary]
  def favorites(username \\ nil) do
    case TheTVDB.API.get("/user/favorites", scope: scope(username)) do
      {:ok, %{"data" => data}} ->
        data["favorites"]
      {:error, reason} ->
          raise reason
    end
  end

  @doc """
  Add a favorite series for a given user.
  """
  @spec add_favorite(username, integer) :: :ok
  def add_favorite(username \\ nil, series_id) do
    endpoint = "/user/favorites/#{series_id}"
    case TheTVDB.API.put(endpoint, "", scope: scope(username)) do
      {:ok, _} ->
        :ok
      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Remove a favorite series for a given user.
  """
  @spec remove_favorite(username, integer) :: :ok
  def remove_favorite(username \\ nil, series_id) do
    endpoint = "/user/favorites/#{series_id}"
    TheTVDB.API.delete(endpoint, scope: scope(username))
  end

  @doc """
  Get a list of all ratings for a given user.
  """
  @spec ratings(username) :: [Rating.t]
  def ratings(username \\ nil) do
    TheTVDB.API.get_stream("/user/ratings", scope: scope(username))
    |> Stream.map(&Rating.from_json/1)
  end

  @doc """
  Add a rating for a given user.

      # Rate a series
      TheTVDB.User.add_rating(:series, series_id, 10.0)
      # => :ok

      # Rate an episode
      TheTVDB.User.add_rating(:episode, episode_id, 10.0)
      # => :ok
      
      # Rate an image
      TheTVDB.User.add_rating(:image, image_id, 10.0)
      # => :ok
  """
  @spec add_rating(username, rating_type, integer, integer) :: :ok
  def add_rating(username \\ nil, type, item, rating)
      when type in @rating_types and is_integer(rating) do
    type = Atom.to_string(type)
    endpoint = "/user/ratings/#{type}/#{item}/#{rating}"
    case TheTVDB.API.put(endpoint, "", scope: scope(username)) do
      {:ok, _} ->
        :ok
      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Remove a rating for a given user.
  """
  @spec remove_rating(username, rating_type, integer) :: :ok
  def remove_rating(username \\ nil, type, item) when type in @rating_types do
    type = Atom.to_string(type)
    endpoint = "/user/ratings/#{type}/#{item}"
    case TheTVDB.API.delete(endpoint, scope: scope(username)) do
      :ok              -> :ok
      {:error, reason} -> raise reason
    end
  end

  defp scope(username) when is_nil(username), do: :user
  defp scope(username), do: {:user, username}
end
