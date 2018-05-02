defmodule AI do
  alias BehaviorTree, as: BT
  alias BehaviorTree.Node

  defstruct [:bt, :target_basis, :current_target, available_points: MapSet.new()]

  def new({cols, rows}) do
    %__MODULE__{
      bt: BT.start(bt()),
      available_points: MapSet.new(0..(cols * rows - 1))
    }
  end

  defp bt do
    # ai logic:
    # guess randomly until getting a hit, then set that as a target and:
    # go right
    #   if sunk, go back to random
    #   if hit, keep going
    #   if miss or invalid:
    # go left from target
    #   same logic...
    # go up from target
    #   same logic...
    # go down from target
    #   same logic...

    search_horizontally = Node.select([:right, :left])

    search_vertically = Node.select([:up, :down])

    narrow_down = Node.select([search_horizontally, search_vertically])

    Node.sequence([:random_guess, narrow_down])
  end

  def hit(ai, point) do
    case BT.value(ai.bt) do
      :random_guess ->
        # locks new target
        %__MODULE__{ai | bt: BT.succeed(ai.bt), target_basis: point, current_target: point}

      _ ->
        update_target(ai, point)
    end
  end

  def miss(ai) do
    case BT.value(ai.bt) do
      :random_guess ->
        ai

      _ ->
        %__MODULE__{ai | bt: BT.fail(ai.bt)} |> retarget
    end
  end

  def sunk(ai) do
    case BT.value(ai.bt) do
      :random_guess ->
        ai

      _ ->
        %__MODULE__{ai | bt: BT.succeed(ai.bt)}
    end
  end

  def make_guess(ai, board) do
    case BT.value(ai.bt) do
      :random_guess ->
        with {:ok, next_guess} <- choose_random_point(ai, board) do
          index = Board.point_to_index(next_guess, board)
          {:ok, next_guess, remove_guess(ai, index)}
        else
          err -> {:error, err}
        end

      direction ->
        with {:ok, next_guess, new_state} <- pick_adjacent(ai, direction, board) do
          index = Board.point_to_index(next_guess, board)

          updated_state = new_state |> update_target(next_guess) |> remove_guess(index)

          {:ok, next_guess, updated_state}
        else
          err -> {:error, err}
        end
    end
  end

  defp pick_adjacent(ai, direction, board) do
    # TODO maybe move this up into make_guess?
    with {:ok, next_guess} <- Board.adjacent(ai.current_target, direction, board) do
      {:ok, next_guess, ai}
    else
      err -> %__MODULE__{ai | bt: BT.fail(ai.bt)} |> retarget |> make_guess(board)
    end
  end

  defp retarget(ai) do
    update_target(ai, ai.target_basis)
  end

  defp update_target(ai, point) do
    %__MODULE__{ai | current_target: point}
  end

  defp choose_random_point(ai, board) do
    guess =
      Enum.random(ai.available_points)
      |> Board.index_to_point(board)

    {:ok, guess}
  end

  defp remove_guess(ai, index) do
    %__MODULE__{ai | available_points: MapSet.delete(ai.available_points, index)}
  end
end
