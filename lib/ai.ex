defmodule AI do
  alias BehaviorTree, as: BT
  alias BehaviorTree.Node

  defstruct [:bt, :target_basis, :current_target, hit_streak: []]

  def new() do
    check_horizontal =
      Node.random([
        Node.select([:right, :left]),
        Node.select([:left, :right])
      ])

    check_vertical =
      Node.random([
        Node.select([:up, :down]),
        Node.select([:down, :up])
      ])

    check_adjacent =
      Node.random([
        Node.select([check_horizontal, check_vertical]),
        Node.select([check_vertical, check_horizontal])
      ])

    bt =
      Node.sequence([
        :random_guess,
        check_adjacent,
        Node.repeat_until_fail(
          Node.sequence([
            :check_for_collateral_damage,
            Node.always_succeed(check_adjacent)
          ])
        )
      ])

    %__MODULE__{bt: BT.start(bt)}
  end

  def hit(ai, point) do
    case BT.value(ai.bt) do
      :random_guess ->
        %__MODULE__{
          ai
          | bt: BT.succeed(ai.bt),
            target_basis: point,
            current_target: point,
            hit_streak: [point | ai.hit_streak]
        }

      :check_for_collateral_damage ->
        # shouldn't ever happen
        ai

      _ ->
        %__MODULE__{ai | current_target: point, hit_streak: [point | ai.hit_streak]}
    end
  end

  def miss(ai) do
    case BT.value(ai.bt) do
      :random_guess ->
        ai

      :check_for_collateral_damage ->
        # shouldn't ever happen
        ai

      _ ->
        %__MODULE__{ai | bt: BT.fail(ai.bt)} |> recenter_target
    end
  end

  def sunk(ai, ship_size) do
    case BT.value(ai.bt) do
      :random_guess ->
        ai

      :check_for_collateral_damage ->
        # shouldn't ever happen
        ai

      direction ->
        ship = ship_points_from_sunk(ship_size, ai.current_target, direction)

        %__MODULE__{
          ai
          | bt: BT.succeed(ai.bt),
            hit_streak: Enum.reject(ai.hit_streak, &Enum.member?(ship, &1))
        }
    end
  end

  def make_guess(ai, board) do
    case BT.value(ai.bt) do
      :random_guess ->
        with {:ok, next_guess} <- choose_random_point(board) do
          {:ok, next_guess, ai}
        else
          err -> {:error, err}
        end

      :check_for_collateral_damage ->
        case ai.hit_streak do
          [] ->
            %__MODULE__{ai | bt: BT.fail(ai.bt)} |> make_guess(board)

          [new_target | remaining_hits] ->
            %__MODULE__{
              ai
              | bt: BT.succeed(ai.bt),
                current_target: new_target,
                target_basis: new_target,
                hit_streak: remaining_hits
            }
            |> make_guess(board)
        end

      direction ->
        with {:ok, next_guess} <- Board.adjacent(ai.current_target, direction, board) do
          {:ok, next_guess, %__MODULE__{ai | current_target: next_guess}}
        else
          err -> %__MODULE__{ai | bt: BT.fail(ai.bt)} |> recenter_target |> make_guess(board)
        end
    end
  end

  defp ship_points_from_sunk(size, {col, row}, :right),
    do: 0..(size - 1) |> Enum.map(fn i -> {col - i, row} end)

  defp ship_points_from_sunk(size, {col, row}, :left),
    do: 0..(size - 1) |> Enum.map(fn i -> {col + i, row} end)

  defp ship_points_from_sunk(size, {col, row}, :up),
    do: 0..(size - 1) |> Enum.map(fn i -> {col, row + i} end)

  defp ship_points_from_sunk(size, {col, row}, :down),
    do: 0..(size - 1) |> Enum.map(fn i -> {col, row - i} end)

  defp recenter_target(ai) do
    %__MODULE__{ai | current_target: ai.target_basis}
  end

  defp choose_random_point(board) do
    guess =
      board
      |> Board.available_indexes()
      |> Enum.random()
      |> Board.index_to_point(board)

    {:ok, guess}
  end
end
