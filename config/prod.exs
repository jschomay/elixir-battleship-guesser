use Mix.Config

config :battleship, Web.Endpoint,
  load_from_system_env: true,
  url: [scheme: "https", host: "elixir-battleship-guesser.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE")

config :logger, level: :info

