defmodule Battleship.CLI do
  def main(_args) do
    IO.puts("\nLet's play Battleship!!\n")
    start_game()
  end

  defp start_game() do
    cols =
      IO.gets("How many columns do you want?\n")
      |> String.trim()
      |> String.to_integer()

    rows =
      IO.gets("\nHow many rows do you want?\n")
      |> String.trim()
      |> String.to_integer()

    Game.start_link({cols, rows})

    IO.gets(
      "\nOK, here is your board.\n\n" <>
        Game.draw() <>
        "\n\nMake a note of where you want to place your ships, and I'll try to sink them.  When you are ready, press <enter>\n"
    )

    play()
  end

  defp show_instructions do
    IO.puts("\n1 = miss, 2 = hit, 3 = sunk, 4 = game over, q = quit")
  end

  defp play do
    {col, row} = Game.make_guess()
    IO.puts("\n" <> Game.draw() <> "\n")
    IO.puts("I guess column " <> Integer.to_string(col) <> ", row " <> Integer.to_string(row))

    show_instructions()

    IO.gets("\n")
    |> String.trim()
    |> execute_command
  end

  defp execute_command("1") do
    Game.miss()
    play()
  end

  defp execute_command("2") do
    Game.hit()
    play()
  end

  defp execute_command("3") do
    IO.gets("\nWhat size ship did I sink?\n")
    |> String.trim()
    |> String.to_integer()
    |> Game.sunk()

    play()
  end

  defp execute_command("4") do
    IO.puts("\nThanks for playing")
  end

  defp execute_command("q") do
    IO.puts("\nThanks for playing")
  end

  defp execute_command(unknown) do
    IO.puts("\nI didn't understand \"" <> unknown <> "\", try again.")

    IO.gets("\n")
    |> String.trim()
    |> execute_command
  end
end
