# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

if File.exists?("config/key.secret.exs") do
  import_config "key.secret.exs"
end

config :deribit,
  base_url: "www.deribit.com",
  test_url: "test.deribit.com",
  client_id: System.get_env("DERIBIT_CLIENT_ID"),
  client_secret: System.get_env("DERIBIT_CLIENT_SECRET"),
  mode: "ws",
  test: false

# mode can also be "websockets" to enable websockets mode
