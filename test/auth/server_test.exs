defmodule TheTVDB.Auth.ServerTest do
  use ExUnit.Case

  @port Application.get_env(:thetvdb, :api_url) |> URI.parse |> Map.get(:port)

  setup do
    bypass = Bypass.open(port: @port)
    {:ok, bypass: bypass}
  end

  test "start_link/1", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.request_path == "/login"
      Plug.Conn.resp(conn, 200, Poison.encode!(%{"token" => "bar"}))
    end

    {:ok, _} = TheTVDB.Auth.Server.start_link("bar")
    assert TheTVDB.Auth.Server.token(:global) == "bar"
  end
end
