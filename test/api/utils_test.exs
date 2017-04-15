defmodule TheTVDB.API.UtilsTest do
  use ExUnit.Case
  import TheTVDB.API.Utils

  test "parse_time/1" do
    assert parse_time("21:00")   == ~T[21:00:00]
    assert parse_time("9:00")    == ~T[09:00:00]
    assert parse_time("09:00")   == ~T[09:00:00]
    assert parse_time("9:00 AM") == ~T[09:00:00]
    assert parse_time("9:00 PM") == ~T[21:00:00]
  end

  test "parse_date/1" do
    assert parse_date("2017-04-05") == ~D[2017-04-05]
  end
end
