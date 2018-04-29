defmodule Board do
  defstruct [:dimensions, :plays]

  def new({cols, rows}) do
    %__MODULE__{dimensions: {cols, rows}, plays: Map.new()}
  end

  def is_game_over(%__MODULE__{dimensions: dimensions, plays: plays}) do
    Enum.count(plays) == size(dimensions)
  end

  def point_to_index({col, row}, {cols, rows})
      when col > 0 and row > 0 and col <= cols and row <= rows do
    (row - 1) * cols + (col - 1)
  end

  def index_to_point(i, {cols, rows}) do
    col = rem(i + 1, cols)
    row = div(i, cols) + 1
    {if(col == 0, do: cols, else: col), row}
  end

  def adjacent({col, row}, direction, {cols, rows}) do
    handle = fn
      :left, {1, _} -> {:error, :left_from_first_col}
      :left, {col, row} -> {col - 1, row}
      :right, {^cols, _} -> {:error, :right_from_last_col}
      :right, {col, row} -> {col + 1, row}
      :up, {_, 1} -> {:error, :up_from_first_row}
      :up, {col, row} -> {col, row - 1}
      :down, {_, ^rows} -> {:error, :downt_from_last_row}
      :down, {col, row} -> {col, row + 1}
    end

    handle.(direction, {col, row})
  end

  def add_play(board = %__MODULE__{}, {{col, row}, symbol}) do
    i = point_to_index({col, row}, board.dimensions)
    new_plays = Map.put(board.plays, i, symbol)
    %__MODULE__{board | plays: new_plays}
  end

  def guess({col, row}) do
    {{col, row}, "_"}
  end

  def hit({col, row}) do
    {{col, row}, "!"}
  end

  def miss({col, row}) do
    {{col, row}, "x"}
  end

  def sunk({col, row}) do
    hit({col, row})
  end

  def draw(%__MODULE__{plays: plays, dimensions: {cols, rows}}) do
    Stream.cycle(["."])
    |> Enum.take(size({cols, rows}))
    |> mark(plays)
    |> Enum.chunk_every(cols)
    |> Enum.map_join("\n\n", fn row -> Enum.join(row, "  ") end)
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
