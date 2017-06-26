defmodule SqlDust.QueryTest do
  use SqlDust.ExUnit.Case

  doctest SqlDust.Query
  import SqlDust.Query

  test "select returns SqlDust containing :select option (passing a string)" do
    query_dust = select("id")

    assert query_dust == %SqlDust{
      select: ["id"]
    }
  end

  test "select returns SqlDust containing :select option (passing a list)" do
    query_dust = select(["id"])

    assert query_dust == %SqlDust{
      select: ["id"]
    }
  end

  test "select appends an argument to existing :select option (passing a string)" do
    query_dust = select("id")
      |> select("name")

    assert query_dust == %SqlDust{
      select: ["id", "name"]
    }
  end

  test "select appends an argument to existing :select option (passing a list)" do
    query_dust = select("id")
      |> select(~w(name))

    assert query_dust == %SqlDust{
      select: ["id", "name"]
    }
  end

  test "passing a string to imply the :from option" do
    query_dust = "users"
      |> select("id")

    assert query_dust == %SqlDust{
      select: ["id"],
      from: "users"
    }
  end

  test "from returns SqlDust containing :from option" do
    query_dust = from("users")

    assert query_dust == %SqlDust{
      from: "users"
    }
  end

  test "from sets :from option of passed SqlDust" do
    query_dust = select("id")
      |> from("users")

    assert query_dust == %SqlDust{
      select: ["id"],
      from: "users"
    }
  end

  test "where returns SqlDust containing :where option (passing a string)" do
    query_dust = where("company.name LIKE '%Engel%'")

    assert query_dust == %SqlDust{
      where: ["company.name LIKE '%Engel%'"]
    }
  end

  test "where returns SqlDust containing :where option (passing a list)" do
    query_dust = where(["company.name LIKE '%Engel%'"])

    assert query_dust == %SqlDust{
      where: [["company.name LIKE '%Engel%'"]]
    }
  end

  test "where appends an argument to existing :where option (passing a string)" do
    query_dust = where("company.name LIKE '%Engel%'")
      |> where("category_id = 1")

    assert query_dust == %SqlDust{
      where: ["company.name LIKE '%Engel%'", "category_id = 1"]
    }
  end

  test "where appends an argument to existing :where option (passing a list)" do
    query_dust = where(["company.name LIKE ?", "%Engel%"])
      |> where(["category_id = ?", 1])

    assert query_dust == %SqlDust{
      where: [
        ["company.name LIKE ?", "%Engel%"],
        ["category_id = ?", 1]
      ]
    }
  end

  test "variables returns SqlDust containing :variables option" do
    query_dust = variables(%{id: 1982})

    assert query_dust == %SqlDust{
      variables: %{id: 1982}
    }
  end

  test "variables merges an argument to existing :variables option" do
    query_dust = variables(%{id: 1982})
      |> variables(%{name: "Paul Engel"})

    assert query_dust == %SqlDust{
      variables: %{id: 1982, name: "Paul Engel"}
    }
  end

  test "group_by returns SqlDust containing :group_by option (passing a string)" do
    query_dust = group_by("company_id")

    assert query_dust == %SqlDust{
      group_by: ["company_id"]
    }
  end

  test "group_by returns SqlDust containing :group_by option (passing a list)" do
    query_dust = group_by(["company_id"])

    assert query_dust == %SqlDust{
      group_by: ["company_id"]
    }
  end

  test "group_by appends an argument to existing :group_by option (passing a string)" do
    query_dust = group_by("company_id")
      |> group_by("category_id")

    assert query_dust == %SqlDust{
      group_by: ["company_id", "category_id"]
    }
  end

  test "group_by appends an argument to existing :group_by option (passing a list)" do
    query_dust = group_by("company_id")
      |> group_by(~w(category_id))

    assert query_dust == %SqlDust{
      group_by: ["company_id", "category_id"]
    }
  end

  test "order_by returns SqlDust containing :order_by option (passing a string)" do
    query_dust = order_by("company_id")

    assert query_dust == %SqlDust{
      order_by: ["company_id"]
    }
  end

  test "order_by returns SqlDust containing :order_by option (passing a list)" do
    query_dust = order_by(["company_id"])

    assert query_dust == %SqlDust{
      order_by: ["company_id"]
    }
  end

  test "order_by appends an argument to existing :order_by option (passing a string)" do
    query_dust = order_by("company_id")
      |> order_by("category_id")

    assert query_dust == %SqlDust{
      order_by: ["company_id", "category_id"]
    }
  end

  test "order_by appends an argument to existing :order_by option (passing a list)" do
    query_dust = order_by("company_id")
      |> order_by(~w(category_id))

    assert query_dust == %SqlDust{
      order_by: ["company_id", "category_id"]
    }
  end

  test "limit returns SqlDust containing :limit option" do
    query_dust = limit(10)

    assert query_dust == %SqlDust{
      limit: 10
    }
  end

  test "limit sets :limit option of passed SqlDust" do
    query_dust = select("id")
      |> limit(10)

    assert query_dust == %SqlDust{
      select: ["id"],
      limit: 10
    }
  end

  test "limit defaults to '?'" do
    query_dust = select("id")
      |> limit

    assert query_dust == %SqlDust{
      select: ["id"],
      limit: "?"
    }
  end

  test "limit overwrites :limit option within passed SqlDust" do
    query_dust = select("id")
      |> limit(10)
      |> limit(100)

    assert query_dust == %SqlDust{
      select: ["id"],
      limit: 100
    }
  end

  test "limit default overwrites :limit option within passed SqlDust" do
    query_dust = select("id")
      |> limit(10)
      |> limit

    assert query_dust == %SqlDust{
      select: ["id"],
      limit: "?"
    }
  end

  test "offset returns SqlDust containing :offset option" do
    query_dust = offset(10)

    assert query_dust == %SqlDust{
      offset: 10
    }
  end

  test "offset sets :offset option of passed SqlDust" do
    query_dust = select("id")
      |> offset(10)

    assert query_dust == %SqlDust{
      select: ["id"],
      offset: 10
    }
  end

  test "offset overwrites :offset option within passed SqlDust" do
    query_dust = select("id")
      |> offset(10)
      |> offset(100)

    assert query_dust == %SqlDust{
      select: ["id"],
      offset: 100
    }
  end

  test "offset defaults to '?'" do
    query_dust = select("id")
      |> offset

    assert query_dust == %SqlDust{
      select: ["id"],
      offset: "?"
    }
  end

  test "offset default overwrites :offset option within passed SqlDust" do
    query_dust = select("id")
      |> offset(10)
      |> offset

    assert query_dust == %SqlDust{
      select: ["id"],
      offset: "?"
    }
  end

  test "unique returns SqlDust containing :unique option (at default true)" do
    query_dust = unique()

    assert query_dust == %SqlDust{
      unique: true
    }
  end

  test "unique returns SqlDust containing :unique option" do
    query_dust = unique(false)

    assert query_dust == %SqlDust{
      unique: false
    }
  end

  test "unique sets :unique option of passed SqlDust" do
    query_dust = select("id")
      |> unique(true)

    assert query_dust == %SqlDust{
      select: ["id"],
      unique: true
    }
  end

  test "unique overwrites :unique option within passed SqlDust" do
    query_dust = select("id")
      |> unique(true)
      |> unique(false)

    assert query_dust == %SqlDust{
      select: ["id"],
      unique: false
    }
  end

  test "schema returns SqlDust containing :schema option" do
    query_dust = schema(%{
      "users": %{
        "skills": %{
          cardinality: :has_and_belongs_to_many
        }
      }
    })

    assert query_dust == %SqlDust{
      schema: %{
        users: %{
          skills: %{
            cardinality: :has_and_belongs_to_many
          }
        }
      }
    }
  end

  test "schema merges argument to existing :schema option" do
    query_dust = schema(
        %{
          "users": %{
            "skills": %{
              cardinality: :has_and_belongs_to_many
            }
          }
        }
      )
      |> schema(
        %{
          "users": %{
            "skills": %{
              "primary_key": "identifier"
            }
          },
          "relations": %{
            table_name: "users"
          }
        }
      )

    assert query_dust == %SqlDust{
      schema: %{
        users: %{
          skills: %{
            cardinality: :has_and_belongs_to_many,
            primary_key: "identifier"
          }
        },
        relations: %{
          table_name: "users"
        }
      }
    }
  end

  test "throwing an error when generating SQL without having assigned the :from option" do
    assert_raise RuntimeError, "missing :from option in query dust", fn ->
      select("id")
        |> to_sql
    end
  end

  test "it generates the select for columns that start with a number" do
    {sql, _} = select("1st_address as 1st_address")
               |> select("second_address")
               |> from("users")
               |> to_sql

    assert sql == """
      SELECT
        `u`.`1st_address` AS `1st_address`,
        `u`.`second_address`
      FROM `users` `u`
      """
  end

  test "it generates the select for columns that ends with a number" do
    {sql, _} = select("address1 as address1")
               |> select("second_address")
               |> from("users")
               |> to_sql

    assert sql == """
      SELECT
        `u`.`address1` AS `address1`,
        `u`.`second_address`
      FROM `users` `u`
      """
  end

  test "escapes fields with same name as function" do
    {sql, _} = select("[regexp] as regexp")
               |> select("[id]")
               |> select("[key.in.value]")
               |> select("'a' REGEXP '^[a-d]'")
               |> select("'Ewout!' REGEXP '.*' as test2")
               |> from("users")
               |> where("[like] = 'ewout'")
               |> to_sql

    assert sql == """
      SELECT
        `u`.`regexp` AS `regexp`,
        `u`.`id`,
        `key.in`.`value`,
        'a' REGEXP '^[a-d]',
        'Ewout!' REGEXP '.*' AS `test2`
      FROM `users` `u`
      LEFT JOIN `keys` `key` ON `key`.`id` = `u`.`key_id`
      LEFT JOIN `ins` `key.in` ON `key.in`.`id` = `key`.`in_id`
      WHERE (`u`.`like` = 'ewout')
      """
  end

  test "generating SQL using composed query dust" do
    sql = select("id, name")
      |> select("company.name")
      |> select("company.address.city")
      |> select("company.1st_address")
      |> from("users")
      |> where(["id > ?", 100])
      |> where(["company.name LIKE ?", "%Engel%"])
      |> join_on(["company.address.is_current = ?", 1])
      |> order_by("name, company.name")
      |> limit(20)
      |> schema(
        %{
          users: %{"table_name": "people"},
          companies: %{"address": %{cardinality: :has_one}}
        }
      )
      |> unique
      |> to_sql

    assert sql == {"""
      SELECT
        `u`.`id`,
        `u`.`name`,
        `company`.`name`,
        `company.address`.`city`,
        `company`.`1st_address`
      FROM `people` `u`
      LEFT JOIN `companies` `company` ON `company`.`id` = `u`.`company_id`
      LEFT JOIN `addresses` `company.address` ON `company.address`.`company_id` = `company`.`id` AND `company.address`.`is_current` = ?
      WHERE (`u`.`id` > ?) AND (`company`.`name` LIKE ?)
      GROUP BY `u`.`id`
      ORDER BY `u`.`name`, `company`.`name`
      LIMIT ?
      """,
      [1, 100, "%Engel%", 20]}
  end

  describe "querying data" do
    test ".to_lists()" do
      assert [
        [1, "Amsterdam"],
        [2, "New York"],
        [3, "Barcelona"],
        [4, "London"]
      ] == "cities" |> to_lists(TestRepo)

      assert [
        "New York",
        "London",
        "Barcelona",
        "Amsterdam"
      ] == "cities" |> select(:name) |> order_by("name DESC") |> to_lists(TestRepo)
    end

    test ".to_maps()" do
      assert [
        %{"id" => 1, "name" => "Amsterdam"},
        %{"id" => 2, "name" => "New York"},
        %{"id" => 3, "name" => "Barcelona"},
        %{"id" => 4, "name" => "London"}
      ] == "cities" |> to_maps(TestRepo)

      assert [
        %{"name" => "New York"},
        %{"name" => "London"},
        %{"name" => "Barcelona"},
        %{"name" => "Amsterdam"}
      ] == "cities" |> select(:name) |> order_by("name DESC") |> to_maps(TestRepo)
    end
  end
end
