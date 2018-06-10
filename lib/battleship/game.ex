defmodule Battleship.Game do
  use GenServer

  alias Battleship.AI
  alias Battleship.Board

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

  def to_json(pid) do
    GenServer.call(pid, :to_json)
  end

  ######

  def handle_call(:is_game_over, _, state) do
    {:reply, Board.game_over?(state.board), state}
  end

  def handle_call(:make_guess, _, state = %__MODULE__{board: board, ai: ai}) do
    with {:ok, guess, new_ai} <- AI.make_guess(ai, board) do
      {:reply, guess, %__MODULE__{state | ai: new_ai, last_guess: guess}}
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
    board_string = Board.draw(state.board, state.last_guess)
    {:reply, board_string, state}
  end

  def handle_call(:to_json, _, state = %{board: board, last_guess: last_guess}) do
    point_to_json = fn {col, row} -> %{col: col, row: row} end

    dimensions_to_json = fn {cols, rows} -> %{cols: cols, rows: rows} end

    map_symbol = fn s ->
      case s do
        "!" -> :hit
        "x" -> :miss
      end
    end

    plays =
      Enum.reduce(board.plays, [], fn {i, symbol}, plays_list ->
        {col, row} = Board.index_to_point(i, board)
        [%{col: col, row: row, status: map_symbol.(symbol)} | plays_list]
      end)

    game = %{
      plays: plays,
      guess: last_guess && point_to_json.(last_guess),
      size: dimensions_to_json.(board.dimensions)
    }

    {:reply, game, state}
  end

  def terminate(reason, state) do
  end
end
