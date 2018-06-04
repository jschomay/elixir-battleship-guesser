defmodule Battleship do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Battleship.Supervisor, []},
      {Web.Endpoint, []}
    ]

    opts = [strategy: :one_for_one, name: BattleshipRoot]
    Supervisor.start_link(children, opts)
  end
end
