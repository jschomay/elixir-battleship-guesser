defmodule Game do
  use GenServer

  defstruct [:ai, :board, :last_guess]

  def start_link({cols, rows}, opts \\ []) do
    GenServer.start_link(__MODULE__, {cols, rows}, opts)
  end

  def init({cols, rows}) do
    state = %__MODULE__{ai: AI.new(), board: Board.new({cols, rows})}
    {:ok, state}
  end

  def draw(pid) do
    GenServer.call(pid, :draw)
  end

  def game_over?(pid) do
    GenServer.call(pid, :is_game_over)
  end

  def make_guess(pid) do
    GenServer.call(pid, :make_guess)
  end

  def hit(pid) do
    GenServer.call(pid, {:outcome, :hit})
  end

  def miss(pid) do
    GenServer.call(pid, {:outcome, :miss})
  end

  def sunk(pid, ship_size) do
    GenServer.call(pid, {:outcome, {:sunk, ship_size}})
  end

  def stop(pid) do
    GenServer.stop(pid)
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

  def terminate(reason, state) do
  end
end
