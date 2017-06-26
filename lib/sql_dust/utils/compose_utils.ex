defmodule SqlDust.ComposeUtils do
  alias SqlDust.MapUtils

  defmacro __using__(_) do
    quote do
      def select(args)                 do select(options(), args) end
      def select(options, args)        do append(options, :select, args) end

      def from(resource)               do from(options(), resource) end
      def from(options, resource)      do __from__(options, resource) end
      defp __from__(options, resource) do put(options, :from, resource) end

      def join_on(statements)          do join_on(options(), statements) end
      def join_on(options, statements) do append(options, :join_on, statements, false) end

      def where(statements)            do where(options(), statements) end
      def where(options, statements)   do append(options, :where, statements, false) end

      def group_by(args)               do group_by(options(), args) end
      def group_by(options, args)      do append(options, :group_by, args) end

      def order_by(args)               do order_by(options(), args) end
      def order_by(options, args)      do append(options, :order_by, args) end

      def limit                        do limit("?") end
      def limit(%{} = options)         do limit(options, "?") end
      def limit(arg)                   do limit(options(), arg) end
      def limit(options, arg)          do put(options, :limit, arg) end

      def offset                       do offset("?") end
      def offset(%{} = options)        do offset(options, "?") end
      def offset(arg)                  do offset(options(), arg) end
      def offset(options, arg)         do put(options, :offset, arg) end

      def unique                       do unique(true) end
      def unique(%{} = options)        do unique(options, true) end
      def unique(bool)                 do unique(options(), bool) end
      def unique(options, bool)        do put(options, :unique, bool) end

      def variables(map)               do variables(options(), map) end
      def variables(options, map)      do merge(options, :variables, map) end

      def adapter(name)                do adapter(options(), name) end
      def adapter(options, name)       do put(options, :adapter, name) end

      def schema(map)                  do schema(options(), map) end
      def schema(options, map)         do merge(options, :schema, map) end

      defp parse(options)              do __parse__(options) end

      defp __parse__(options) do
        if is_bitstring(options) do
          from(options)
        else
          options
        end
      end

      defp options do
        %SqlDust{}
      end

      defp put(options, key, value) do
        Map.put(parse(options), key, value)
      end

      defp append(options, key, value, concat \\ true) do
        options = parse(options)
        list = Map.get(options, key) || []

        list =
          if concat do
            list |> Enum.concat(List.wrap(value))
          else
            list |> List.insert_at(-1, value)
          end

        Map.put options, key, list
      end

      defp merge(options, key, value) do
        options = parse(options)
        value = (Map.get(options, key) || %{})
          |> MapUtils.deep_merge(value)

        Map.put options, key, value
      end

      defoverridable [from: 2, parse: 1]
    end
  end
end
