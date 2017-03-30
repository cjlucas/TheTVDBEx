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
end
