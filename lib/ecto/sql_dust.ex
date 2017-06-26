defmodule Ecto.SqlDust do
  use SqlDust.QueryUtils

  def from(options, struct) do
    source = struct.__schema__(:source)
    derived_schema = derive_schema(struct)

    options
      |> __from__(source)
      |> schema(derived_schema)
      |> ecto_schema(struct)
      |> adapter(:postgres)
  end

  def ecto_schema(options, arg) do
    put(options, :ecto_schema, arg)
  end

  def to_structs(options, repo) do
    %{columns: columns, rows: rows} = query(options, repo)

    columns = columns |> Enum.map(&String.to_atom/1)
    ecto_schema = parse(options).ecto_schema

    Enum.map(rows, fn(row) ->
      Ecto.Schema.__load__(ecto_schema, nil, nil, nil, {columns, row},
                           &Ecto.Type.adapter_load(repo.config[:adapter], &1, &2))
    end)
  end

  defp parse(options) do
    try do
      case options.__struct__ do
        SqlDust -> options
        _ -> from(options)
      end
    catch
      _ -> __parse__(options)
    end
  end

  defp derive_schema(model) do
    derive_schema(%{}, model)
  end

  defp derive_schema(schema, model) do
    source = model.__schema__(:source)
    associations = model.__schema__(:associations)

    schema = schema
      |> Map.put(source, Enum.reduce(associations, %{name: source, table_name: source}, fn(association, map) ->
        reflection = model.__schema__(:association, association)
        Map.put(map, association, derive_association(reflection))
      end))

    schema = associations
      |> Enum.map(fn(association) ->
        model.__schema__(:association, association).queryable
      end)
      |> Enum.uniq
      |> Enum.reduce(schema, fn(model, schema) ->
        model_source = model.__schema__(:source)
        if (source == model_source) || Map.has_key?(schema, model_source) do
          schema
        else
          derive_schema(schema, model)
        end
      end)

    schema
  end

  defp derive_association(reflection) do
    cardinality = case reflection.__struct__ do
      Ecto.Association.BelongsTo -> :belongs_to
      Ecto.Association.Has ->
        case reflection.cardinality do
          :one -> :has_one
          :many -> :has_many
        end
      Ecto.Association.ManyToMany -> :has_and_belongs_to_many
    end

    Map.merge(%{
      cardinality: cardinality,
      resource: reflection.related.__schema__(:source)
    }, derive_association(cardinality, reflection))
  end

  defp derive_association(:belongs_to, reflection) do
    %{
      primary_key: Atom.to_string(reflection.related_key),
      foreign_key: Atom.to_string(reflection.owner_key)
    }
  end

  defp derive_association(:has_one, reflection) do
    %{
      primary_key: Atom.to_string(reflection.owner_key),
      foreign_key: Atom.to_string(reflection.related_key)
    }
  end

  defp derive_association(:has_many, reflection) do
    %{
      primary_key: Atom.to_string(reflection.owner_key),
      foreign_key: Atom.to_string(reflection.related_key)
    }
  end

  # ???
  # defp derive_association(:has_and_belongs_to_many, reflection) do
  #   %{
  #     # bridge_table: ([Inflex.pluralize(resource), Inflex.pluralize(association)] |> Enum.sort |> Enum.join("_")),
  #     # primary_key: "id",
  #     # foreign_key: "#{Inflex.singularize(resource)}_id",
  #     # association_primary_key: "id",
  #     # association_foreign_key: "#{Inflex.singularize(association)}_id"
  #   }
  # end
end
