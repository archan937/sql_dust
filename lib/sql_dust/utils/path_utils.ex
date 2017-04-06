defmodule SqlDust.PathUtils do
  import SqlDust.ScanUtils

  def prepend_path_aliases(sql, options) when sql == "*" do
    {sql, options}
  end
require IEx
  def prepend_path_aliases(sql, options) when is_list(sql) do
    list = prepend_path_aliases2(sql, options)
    {aliases, excluded} = list
     |> Enum.reduce({[], []}, fn({sql, aliases, excluded}, {aliases_list, excluded_list}) ->
       {[aliases | aliases_list], [[sql, excluded] | excluded_list]}
     end)
     options = %{options | aliases: aliases |> List.flatten |> Enum.uniq |> Enum.reverse}
     {sql, options} = excluded |> Enum.reduce({[], options}, fn([sql, excluded], {list, options}) ->
        sql = numerize_patterns(sql, excluded)
        {sql, options} = scan_and_prepend_path_aliases(sql, options)

        sql = interpolate_patterns(sql, excluded)
        {[sql | list], options}
     end)
    {sql,options}
  end

  def prepend_path_aliases2([head] = list, options) do
    [prepend_path_aliases2(head, options)]
  end

  def prepend_path_aliases2([head|rest], options) do
    [prepend_path_aliases2(head, options)|prepend_path_aliases2(rest, options)]
  end

  def prepend_path_aliases2(sql, options) when is_binary(sql) do
    {excluded, aliases} = scan_excluded(sql)

    aliases =
      aliases
      |> Enum.map(fn
        (" AS " <> sql_alias) -> sql_alias
        (" as " <> sql_alias) -> sql_alias
        (sql_alias) -> sql_alias
      end)

    excluded = excluded
      |> Enum.map(fn(excluded) ->
        regex = ~r/^( AS )(.+)/i
        if Regex.match?(regex, excluded) do
          {_, compiled} = Regex.compile(excluded)
          [compiled, Regex.replace(regex, excluded, fn(_, as, path) ->
            as <> quote_alias(path, options)
          end)]
        else
          excluded
        end
      end)
      |> Enum.concat(Enum.map(aliases, fn(sql_alias) ->
        [~r/([^\.\w])#{sql_alias}([^\.\w])/, quote_alias(sql_alias, options)]
      end))
    {sql, aliases, excluded}
  end

  def prepend_path_aliases(sql, options) do
    {excluded, aliases} = scan_excluded(sql)

    aliases = aliases
      |> Enum.map(fn(sql_alias) ->
        String.replace(sql_alias, ~r/^ AS /i, "")
      end)
      |> Enum.concat(options.aliases)
      |> Enum.uniq

    excluded = excluded
      |> Enum.map(fn(excluded) ->
        regex = ~r/^( AS )(.+)/i
        if Regex.match?(regex, excluded) do
          {_, compiled} = Regex.compile(excluded)
          [compiled, Regex.replace(regex, excluded, fn(_, as, path) ->
            as <> quote_alias(path, options)
          end)]
        else
          excluded
        end
      end)
      |> Enum.concat(Enum.map(aliases, fn(sql_alias) ->
        [~r/([^\.\w])#{sql_alias}([^\.\w])/, quote_alias(sql_alias, options)]
      end))

    options = Map.put(options, :aliases, aliases)

    sql = numerize_patterns(sql, excluded)
    {sql, options} = scan_and_prepend_path_aliases(sql, options)

    sql = interpolate_patterns(sql, excluded)
    {sql, options}
  end

  def calculate_aliases([head|rest], options) do
    {excluded, aliases} = scan_excluded(head)

    aliases = aliases
          |> Enum.map(fn(sql_alias) ->
            String.replace(sql_alias, ~r/^ AS /i, "")
          end)
  end

  def sanitize_sql(sql) do
    {excluded, _} = scan_excluded(sql)
    Enum.reduce(excluded, sql, fn(pattern, sql) ->
      String.replace(sql, pattern, "")
    end)
  end

  def scan_excluded(sql) do
    excluded = []
      |> Enum.concat(scan_quoted(sql))
      |> Enum.concat(scan_variables(sql))
      |> Enum.concat(scan_functions(sql))
      |> Enum.concat(aliases = scan_aliases(sql) |> List.flatten |> Enum.uniq)
      |> Enum.concat(scan_reserved_words(sql))
      |> List.flatten
      |> Enum.uniq

    {excluded, aliases}
  end

  defp scan_and_prepend_path_aliases(sql, options) do
    regex = ~r/(?:\.\*|\w+[a-zA-Z]+\w*(?:\.(?:\*|\w{2,}))*)/

    paths = Regex.scan(regex, sql)
    sql = Regex.replace(regex, sql, fn(match) ->
      "{#{match}}"
    end)

    Enum.reduce(paths, {sql, options}, fn([path], {sql, options}) ->
      {path_alias, options} = prepend_path_alias(path, options, true)
      {String.replace(sql, "{#{path}}", path_alias), options}
    end)
  end

  def prepend_path_alias(path, options, cascade \\ false) do
    {path, column} = do_dissect_path(path, options)

    options =
      if cascade do
        paths = Enum.concat(options[:paths], cascaded_paths(path))
        Map.put(options, :paths, paths)
      else
        options
      end

    path_alias = derive_path_alias(path, options)

    {"#{quote_alias(path_alias, options)}.#{quote_alias(column, options)}", options}
  end

  def dissect_path(path, options) do
    {path, column} = do_dissect_path(path, options)
    {Enum.join(path, "."), column}
  end

  defp do_dissect_path(path, options) do

    quotation_mark = quotation_mark(options)
    split_on_dot_outside_quotation_mark = ~r/\.(?=(?:[^#{quotation_mark}]*#{quotation_mark}[^#{quotation_mark}]*#{quotation_mark})*[^#{quotation_mark}]*$)/
    segments = String.split(path, split_on_dot_outside_quotation_mark)

    case Enum.split(segments, -1) do
      {prefix, [last]} -> {prefix, last}
      {[], []} -> {[], nil}
    end
  end

  defp cascaded_paths(path) when is_bitstring(path) do
    cascaded_paths(String.split(path, "."))
  end

  defp cascaded_paths(path) do
    Enum.reduce(path, [], fn
      (segment, paths) when segment in [nil, ""] -> paths
      (segment, []) -> [segment]
      (segment, [h | _] = paths) -> [Enum.join([h, segment], ".")|paths]
    end)
    |> :lists.reverse()
  end

  def derive_quoted_path_alias(path, options) do
    quote_alias(derive_path_alias(path, options), options)
  end

  defp derive_path_alias(path, options) when is_list(path) do
    derive_path_alias(Enum.join(path, "."), options)
  end

  defp derive_path_alias(path, options) do
    case String.replace(path, quotation_mark(options), "") do
      "" -> String.downcase(String.at(options.resource.name, 0))
      _ -> path
    end
  end

  def quotation_mark(%{adapter: :mysql}) do
    "`"
  end

  def quotation_mark(_) do
    "\""
  end

  def quote_alias("*" = sql, _) do
    sql
  end

  def quote_alias(sql, options) do
    quotation_mark = quotation_mark(options)
    if Regex.match?(~r/\A#{quotation_mark}.*#{quotation_mark}\z/, sql) do
      sql
    else
      quotation_mark <> sql <> quotation_mark
    end
  end
end
