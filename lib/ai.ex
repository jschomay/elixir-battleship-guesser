defmodule AI do
  defstruct [:last_guess, :board_size, available_points: MapSet.new()]

  def new({cols, rows}) do
    %__MODULE__{available_points: MapSet.new(0..(cols * rows - 1)), board_size: {cols, rows}}
  end

  def hit(state) do
    state
  end

  def miss(state) do
    state
  end

  def sunk(state) do
    state
  end

  def make_guess(state) do
    case get_strategy(state) do
      :random ->
        with {:ok, point} <- choose_random_point(state),
             {:ok, new_state} <- update_with_guess(state, point) do
          {:ok, point, new_state}
        else
          err -> {:error, err}
        end
    end
  end

  def remaining(state) do
    state.available_points
  end

  defp get_strategy(state) do
    # BT goes here...
    # :try_right
    # :try_left
    # :try_up
    # :try_down
    :random
  end

  defp choose_random_point(state) do
    guess =
      Enum.random(state.available_points)
      |> Board.index_to_point(state.board_size)

    {:ok, guess}
  end

  defp update_with_guess(state, point) do
    index = Board.point_to_index(point, state.board_size)

    new_state = %__MODULE__{
      state
      | available_points: MapSet.delete(state.available_points, index),
        last_guess: point
    }

    {:ok, new_state}
  end
end
