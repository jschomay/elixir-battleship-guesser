defmodule Board do
  defstruct [:dimensions, :plays]

  def new({cols, rows}) do
    %__MODULE__{dimensions: {cols, rows}, plays: Map.new()}
  end

  def game_over?(%__MODULE__{dimensions: dimensions, plays: plays}) do
    Enum.count(plays) == size(dimensions)
  end

  def point_to_index({col, row}, %__MODULE__{dimensions: {cols, rows}})
      when col > 0 and row > 0 and col <= cols and row <= rows do
    (row - 1) * cols + (col - 1)
  end

  def index_to_point(i, %__MODULE__{dimensions: {cols, rows}}) do
    col = rem(i + 1, cols)
    row = div(i, cols) + 1
    {if(col == 0, do: cols, else: col), row}
  end

  def already_played?(board = %__MODULE__{}, point) do
    i = point_to_index(point, board)
    Enum.member?(Map.keys(board.plays), i)
  end

  def adjacent(point, direction, board = %__MODULE__{dimensions: {cols, rows}}) do
    handle = fn
      :left, {1, _} -> {:error, :off_board}
      :right, {^cols, _} -> {:error, :off_board}
      :up, {_, 1} -> {:error, :off_board}
      :down, {_, ^rows} -> {:error, :off_board}
      :left, {col, row} -> {:ok, {col - 1, row}}
      :right, {col, row} -> {:ok, {col + 1, row}}
      :up, {col, row} -> {:ok, {col, row - 1}}
      :down, {col, row} -> {:ok, {col, row + 1}}
    end

    with {:ok, adjacent_point} <- handle.(direction, point) do
      if already_played?(board, adjacent_point) do
        {:error, :already_played}
      else
        {:ok, adjacent_point}
      end
    else
      err -> {:error, err}
    end
  end

  def add_play(board = %__MODULE__{}, {point, symbol}) do
    i = point_to_index(point, board)
    new_plays = Map.put(board.plays, i, symbol)
    %__MODULE__{board | plays: new_plays}
  end

  def guess(point) do
    {point, "o"}
  end

  def hit(point) do
    {point, "!"}
  end

  def miss(point) do
    {point, "x"}
  end

  def sunk(point) do
    hit(point)
  end

  def draw(%__MODULE__{plays: plays, dimensions: {cols, rows}}) do
    Stream.cycle(["."])
    |> Enum.take(size({cols, rows}))
    |> mark(plays)
    |> Enum.chunk_every(cols)
    |> Enum.map_join("\n", fn row -> Enum.join(row, "  ") end)
    |> IO.puts()
  end

  defp size({cols, rows}) do
    rows * cols
  end

  defp mark(empty_board, plays) do
    Enum.reduce(plays, empty_board, fn {i, symbol}, board ->
      List.replace_at(board, i, symbol)
    end)
  end
end
