defmodule TheTVDB.ModelTest do
  use ExUnit.Case

  defmodule SimpleModel do
    use TheTVDB.Model

    model do
      field "one"
      field "two"
    end
  end 

  defmodule CrazyCasingModel do
    use TheTVDB.Model

    model do
      field "fieldOne"
      field "two"
    end
  end

  defmodule TypesModel do
    use TheTVDB.Model

    model do
      field "one", type: :time
      field "two", type: :date
      field "three", type: :integer
      field "four", type: :datetime
      field "five", type: :unix_timestamp
    end
  end

  test "SimpleModel struct definition" do
    model = %SimpleModel{}
    assert Map.has_key?(model, :one)
    assert Map.has_key?(model, :two)
  end
  
  test "CrazyCasingModel struct definition" do
    model = %CrazyCasingModel{}
    assert Map.has_key?(model, :field_one)
    assert Map.has_key?(model, :two)
  end

  test "SimpleModel JSON decoder implementation" do
    json = """
    {
    "one": 5,
    "two": [
      "foo",
      "bar"
    ]
    }
    """

    expected = %SimpleModel{one: 5, two: ["foo", "bar"]}

    assert Poison.decode!(json) |> SimpleModel.from_json == expected
  end
  
  test "CrazyCasingModel JSON decoder implementation" do
    json = """
    {
    "two": [
      "foo",
      "bar"
    ],
    "fieldOne": 5
    }
    """

    expected = %CrazyCasingModel{field_one: 5, two: ["foo", "bar"]}

    assert Poison.decode!(json) |> CrazyCasingModel.from_json == expected
  end

  test "TypesModel JSON decoder implementation w/ values" do
    json = """
    {
    "one": "21:00",
    "two": "2017-04-17",
    "three": "30",
    "four": "2016-05-28 21:06:24",
    "five": 1492277041
    }
    """

    expected = %TypesModel{
      one: ~T[21:00:00],
      two: ~D[2017-04-17],
      three: 30,
      four: ~N[2016-05-28 21:06:24],
      five: Timex.from_unix(1492277041)
    }

    assert Poison.decode!(json) |> TypesModel.from_json == expected
  end
  
  test "TypesModel JSON decoder implementation w/ null fields" do
    json = """
    {
    "one": null,
    "two": null,
    "three": null,
    "four": null,
    "five": null
    }
    """

    expected = %TypesModel{}

    assert Poison.decode!(json) |> TypesModel.from_json == expected
  end
  
  test "TypesModel JSON decoder implementation w/ empty string values" do
    json = """
    {
    "one": "",
    "two": "",
    "three": "",
    "four": "",
    "five": ""
    }
    """

    expected = %TypesModel{}

    assert Poison.decode!(json) |> TypesModel.from_json == expected
  end
end
