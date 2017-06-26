defmodule SqlDust.QueryUtils do
  defmacro __using__(_) do
    quote do
      use SqlDust.ComposeUtils

      def to_sql(options) do
        options = parse(options)

        if (is_nil(options.from)) do;
          raise "missing :from option in query dust"
        end

        from = options.from
        schema = options.schema
        options = Map.take(options, [:select, :join_on, :where, :group_by, :order_by, :limit, :offset, :unique, :variables, :adapter])
                  |> Enum.reduce(%{from: options.from}, fn
                    ({_key,  nil}, map) -> map
                    ({key, value}, map) -> Map.put(map, key, value)
                  end)

        SqlDust.from(from, options, schema || %{})
      end

      def to_lists(options, repo) do
        %{columns: columns, rows: rows} = query(options, repo)

        case length(columns) do
          1 -> List.flatten(rows)
          _ -> rows
        end
      end

      def to_maps(options, repo) do
        %{columns: columns, rows: rows} = query(options, repo)

        rows
        |> Enum.map(fn(row) ->
          columns
          |> Enum.zip(row)
          |> Enum.into(%{})
        end)
      end

      defp query(options, repo) do
        repo_adapter =
          repo.config[:adapter]
          |> Module.split()
          |> Enum.at(-1)
          |> String.downcase()
          |> String.to_atom()

        [sql, vars] =
          options
          |> adapter(repo_adapter)
          |> to_sql()
          |> Tuple.to_list
          |> Enum.take(2)

        Ecto.Adapters.SQL.query!(repo, sql, vars)
      end

    end
  end
end
