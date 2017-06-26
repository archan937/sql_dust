ExUnit.start()

defmodule SqlDust.ExUnit.Case do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
    :ok = Ecto.Adapters.SQL.Sandbox.mode(TestRepo, {:shared, self()})

    Ecto.Adapters.SQL.query!(TestRepo, "TRUNCATE `cities`", [])
    Ecto.Adapters.SQL.query!(TestRepo, "INSERT INTO `cities` (`id`, `name`) VALUES (1, 'Amsterdam')", [])
    Ecto.Adapters.SQL.query!(TestRepo, "INSERT INTO `cities` (`id`, `name`) VALUES (2, 'New York')", [])
    Ecto.Adapters.SQL.query!(TestRepo, "INSERT INTO `cities` (`id`, `name`) VALUES (3, 'Barcelona')", [])
    Ecto.Adapters.SQL.query!(TestRepo, "INSERT INTO `cities` (`id`, `name`) VALUES (4, 'London')", [])

    :ok
  end
end

{:ok, _pid} = TestRepo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(TestRepo, {:shared, self()})
