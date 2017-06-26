use Mix.Config

config :sql_dust, TestRepo,[
  adapter: Ecto.Adapters.MySQL,
  database: "sql_dust_test",
  username: "root",
  password: "",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
]

config :sql_dust, ecto_repos: [TestRepo]
config :logger, level: :info
