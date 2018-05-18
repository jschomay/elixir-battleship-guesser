defmodule Game do
  use GenServer

  defstruct [:ai, :board, :last_guess]

  def start_link({cols, rows}) do
    GenServer.start_link(__MODULE__, {cols, rows}, name: __MODULE__)
  end

  def init({cols, rows}) do
    state = %__MODULE__{ai: AI.new(), board: Board.new({cols, rows})}
    {:ok, state}
  end

  def draw do
    GenServer.call(__MODULE__, :draw)
  end

  def game_over? do
    GenServer.call(__MODULE__, :is_game_over)
  end

  def make_guess do
    GenServer.call(__MODULE__, :make_guess)
  end

  def hit() do
    GenServer.call(__MODULE__, {:outcome, :hit})
  end

  def miss() do
    GenServer.call(__MODULE__, {:outcome, :miss})
  end

  def sunk(ship_size) do
    GenServer.call(__MODULE__, {:outcome, {:sunk, ship_size}})
  end

  def winner do
    GenServer.cast(__MODULE__, :winner)
  end

  ######

  def handle_call(:is_game_over, _, state) do
    {:reply, Board.game_over?(state.board), state}
  end

  def handle_call(:make_guess, _, state = %__MODULE__{board: board, ai: ai}) do
    with {:ok, guess, new_ai} <- AI.make_guess(ai, board),
         new_board <- Board.add_play(board, Board.guess(guess)) do
      {:reply, guess, %__MODULE__{state | board: new_board, ai: new_ai, last_guess: guess}}
    else
      err -> {:stop, err, state}
    end
  end

  def handle_call({:outcome, outcome}, _, state) do
    case outcome do
      :hit ->
        new_ai = AI.hit(state.ai, state.last_guess)

        new_board = Board.add_play(state.board, Board.hit(state.last_guess))

        {:reply, :ok, %__MODULE__{state | board: new_board, ai: new_ai}}

      :miss ->
        new_ai = AI.miss(state.ai)

        new_board = Board.add_play(state.board, Board.miss(state.last_guess))

        {:reply, :ok, %__MODULE__{state | board: new_board, ai: new_ai}}

      {:sunk, ship_size} ->
        new_ai = AI.sunk(state.ai, ship_size)

        new_board = Board.add_play(state.board, Board.sunk(state.last_guess))

        {:reply, :ok, %__MODULE__{state | board: new_board, ai: new_ai}}
    end
  end

  def handle_call(:draw, _, state) do
    board_string = Board.draw(state.board)
    {:reply, board_string, state}
  end

  def handle_cast(:winner, state) do
    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    IO.puts("The server terminated")
  end
end
