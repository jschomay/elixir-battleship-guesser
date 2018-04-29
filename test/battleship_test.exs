defmodule BattleshipTest do
  use ExUnit.Case
  doctest Battleship

  test "greets the world" do
    assert Battleship.hello() == :world
  end
end
