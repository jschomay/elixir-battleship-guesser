defmodule Battleship.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Battleship.GameSupervisor, strategy: :one_for_one},
      {Battleship.Registry, name: Battleship.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
