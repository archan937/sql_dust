defmodule Test do
  defmodule Weather do
    use Ecto.Schema
    schema "weather" do
      belongs_to :city, Test.City
    end
  end

  defmodule City do
    use Ecto.Schema
    schema "cities" do
      field :name, :string
      has_many :local_weather, Test.Weather
      belongs_to :country, Test.Country
    end
  end

  defmodule Country do
    use Ecto.Schema
    schema "countries" do
      has_many :cities, Test.City
      # has_many :weather, through: [:cities, :local_weather] ???
    end
  end
end

defmodule Ecto.SqlDustTest do
  use SqlDust.ExUnit.Case
  doctest Ecto.SqlDust
  import Ecto.SqlDust

  test "generates simple SQL based on Ecto model schemas" do
    sql = Test.Weather
      |> to_sql

    assert sql == {"""
      SELECT "w".*
      FROM "weather" "w"
      """, []}
  end

  test "generates simple SQL based on Ecto model schemas (using from)" do
    sql = from(Test.Weather)
      |> to_sql

    assert sql == {"""
      SELECT "w".*
      FROM "weather" "w"
      """, []}
  end

  test "generates SQL based on Ecto model schemas" do
    sql = Test.City
      |> select("id, name, country.name, local_weather.temp_lo, local_weather.temp_hi")
      |> where("local_weather.wdate = '2015-09-12'")
      |> to_sql

    assert sql == {"""
      SELECT
        "c"."id",
        "c"."name",
        "country"."name",
        "local_weather"."temp_lo",
        "local_weather"."temp_hi"
      FROM "cities" "c"
      LEFT JOIN "countries" "country" ON "country"."id" = "c"."country_id"
      LEFT JOIN "weather" "local_weather" ON "local_weather"."city_id" = "c"."id"
      WHERE ("local_weather"."wdate" = '2015-09-12')
      """, []}
  end

  test "support generating SQL based on Ecto model schemas for MySQL" do
    sql = Test.City
      |> select("id, name, country.name, local_weather.temp_lo, local_weather.temp_hi")
      |> where(["local_weather.wdate = ?", "2015-09-12"])
      |> adapter(:mysql)
      |> to_sql

    assert sql == {"""
      SELECT
        `c`.`id`,
        `c`.`name`,
        `country`.`name`,
        `local_weather`.`temp_lo`,
        `local_weather`.`temp_hi`
      FROM `cities` `c`
      LEFT JOIN `countries` `country` ON `country`.`id` = `c`.`country_id`
      LEFT JOIN `weather` `local_weather` ON `local_weather`.`city_id` = `c`.`id`
      WHERE (`local_weather`.`wdate` = ?)
      """, ["2015-09-12"]}
  end

  describe "querying data" do
    test ".to_lists()" do
      assert [
        [1, "Amsterdam"],
        [2, "New York"],
        [3, "Barcelona"],
        [4, "London"]
      ] == Test.City |> to_lists(TestRepo)

      assert [
        "New York",
        "London",
        "Barcelona",
        "Amsterdam"
      ] == Test.City |> select(:name) |> order_by("name DESC") |> to_lists(TestRepo)
    end

    test ".to_maps()" do
      assert [
        %{"id" => 1, "name" => "Amsterdam"},
        %{"id" => 2, "name" => "New York"},
        %{"id" => 3, "name" => "Barcelona"},
        %{"id" => 4, "name" => "London"}
      ] == Test.City |> to_maps(TestRepo)

      assert [
        %{"name" => "New York"},
        %{"name" => "London"},
        %{"name" => "Barcelona"},
        %{"name" => "Amsterdam"}
      ] == Test.City |> select(:name) |> order_by("name DESC") |> to_maps(TestRepo)
    end

    test ".to_structs()" do
      assert [
        %Test.City{id: 1, name: "Amsterdam"},
        %Test.City{id: 2, name: "New York"},
        %Test.City{id: 3, name: "Barcelona"},
        %Test.City{id: 4, name: "London"}
      ] = Test.City |> to_structs(TestRepo)

      assert [
        %Test.City{id: 2, name: "New York"},
        %Test.City{id: 4, name: "London"},
        %Test.City{id: 3, name: "Barcelona"},
        %Test.City{id: 1, name: "Amsterdam"}
      ] = Test.City |> order_by("name DESC") |> to_structs(TestRepo)
    end
  end

end
