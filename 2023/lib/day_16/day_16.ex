defmodule Day16.Day16 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.graphemes()
  end

  def part_a(grid) do
    run_ray(grid, {0, 0}, {1, 0}) |> count_energized()
  end

  def run_ray(grid, {x, y}, {dx, dy}, visited \\ MapSet.new()) do
    if already_visited?(visited, {x, y}, {dx, dy}) or not in_bounds?(grid, {x, y}) do
      visited
    else
      visited = mark_visited(visited, {x, y}, {dx, dy})

      symbol =
        grid
        |> Enum.at(y)
        |> Enum.at(x)

      case symbol do
        "." -> pass_through(grid, {x, y}, {dx, dy}, visited)
        "|" -> handle_vertical_splitter(grid, {x, y}, {dx, dy}, visited)
        "-" -> handle_horizontal_splitter(grid, {x, y}, {dx, dy}, visited)
        "\\" -> handle_backslash_mirror(grid, {x, y}, {dx, dy}, visited)
        "/" -> handle_forwardslash_mirror(grid, {x, y}, {dx, dy}, visited)
      end
    end
  end

  defp mark_visited(visited, {x, y}, {dx, dy}) do
    MapSet.put(visited, {{x, y}, {dx, dy}})
  end

  defp already_visited?(visited, {x, y}, {dx, dy}) do
    MapSet.member?(visited, {{x, y}, {dx, dy}})
  end

  defp in_bounds?(grid, {x, y}) do
    x >= 0 && x < Enum.count(grid) && y >= 0 && y < Enum.count(Enum.at(grid, 0))
  end

  defp pass_through(grid, pos, dir, visited) do
    run_ray(grid, move(pos, dir), dir, visited)
  end

  defp move({x, y}, {dx, dy}), do: {x + dx, y + dy}
  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :right), do: {x + 1, y}
  defp move({x, y}, :down), do: {x, y + 1}
  defp move({x, y}, :left), do: {x - 1, y}

  defmacro direction(direction_atom) do
    case direction_atom do
      quote(do: :up) -> quote(do: {0, -1})
      quote(do: :right) -> quote(do: {1, 0})
      quote(do: :down) -> quote(do: {0, 1})
      quote(do: :left) -> quote(do: {-1, 0})
    end
  end

  defp direction_func(direction_atom) do
    case direction_atom do
      :up -> {0, -1}
      :right -> {1, 0}
      :down -> {0, 1}
      :left -> {-1, 0}
    end
  end

  # |
  defp handle_vertical_splitter(grid, pos, {dx, dy}, visited) do
    if dx != 0 do
      run_ray(grid, move(pos, :up), direction(:up), visited)
      |> then(fn visited ->
        run_ray(grid, move(pos, :down), direction(:down), visited)
      end)
    else
      pass_through(grid, pos, {dx, dy}, visited)
    end
  end

  # -
  defp handle_horizontal_splitter(grid, pos, {dx, dy}, visited) do
    if dy != 0 do
      run_ray(grid, move(pos, :left), direction(:left), visited)
      |> then(fn visited ->
        run_ray(grid, move(pos, :right), direction(:right), visited)
      end)
    else
      pass_through(grid, pos, {dx, dy}, visited)
    end
  end

  defp handle_backslash_mirror(grid, pos, dir, visited) do
    # \
    case dir do
      direction(:up) -> run_ray(grid, move(pos, :left), direction(:left), visited)
      direction(:down) -> run_ray(grid, move(pos, :right), direction(:right), visited)
      direction(:left) -> run_ray(grid, move(pos, :up), direction(:up), visited)
      direction(:right) -> run_ray(grid, move(pos, :down), direction(:down), visited)
    end
  end

  defp handle_forwardslash_mirror(grid, pos, dir, visited) do
    # /
    case dir do
      # from below to right
      direction(:up) -> run_ray(grid, move(pos, :right), direction(:right), visited)
      # from above to left
      direction(:down) -> run_ray(grid, move(pos, :left), direction(:left), visited)
      # from left to above
      direction(:left) -> run_ray(grid, move(pos, :down), direction(:down), visited)
      # from right to below
      direction(:right) -> run_ray(grid, move(pos, :up), direction(:up), visited)
    end
  end

  def count_energized(visited) do
    visited |> Enum.map(fn {{x, y}, _} -> {x, y} end) |> MapSet.new() |> MapSet.size()
  end

  def part_b(grid) do
    {n_rows, n_cols} = {Enum.count(grid), Enum.count(Enum.at(grid, 0))}

    [
      {:right, fn y -> {0, y} end, 0..(n_rows - 1)},
      {:left, fn y -> {n_cols - 1, y} end, 0..(n_rows - 1)},
      {:down, fn x -> {x, 0} end, 0..(n_cols - 1)},
      {:up, fn x -> {x, n_rows - 1} end, 0..(n_cols - 1)}
    ]
    |> Enum.map(&calculate_direction_rays(grid, &1))
    |> List.flatten()
    |> Enum.max()
  end

  defp calculate_direction_rays(grid, {direction_atom, start_pos_fun, range}) do
    Enum.map(range, fn pos ->
      start_pos = start_pos_fun.(pos)

      run_ray(
        grid,
        start_pos,
        direction_atom |> direction_func,
        MapSet.new()
      )
      |> count_energized()
    end)
  end

  # DEBUGGING ----

  # def get_energized(visited) do
  #   visited |> Enum.map(fn {{x, y}, _} -> {x, y} end) |> MapSet.new()
  # end

  # defp visualize_energized(grid, energized) do
  #   grid
  #   |> Enum.with_index()
  #   |> Enum.map(fn {row, y} ->
  #     row
  #     |> Enum.with_index()
  #     |> Enum.map(fn {symbol, x} ->
  #       if MapSet.member?(energized, {x, y}) do
  #         "#"
  #       else
  #         "."
  #       end
  #     end)
  #   end)
  # end

  # for debugging
  # defp visualize_visited(grid, visited) do
  #   grid
  #   |> Enum.with_index()
  #   |> Enum.map(fn {row, y} ->
  #     row
  #     |> Enum.with_index()
  #     |> Enum.map(fn {symbol, x} ->
  #       up_visited = already_visited?(visited, {x, y}, direction(:up))
  #       right_visited = already_visited?(visited, {x, y}, direction(:right))
  #       down_visited = already_visited?(visited, {x, y}, direction(:down))
  #       left_visited = already_visited?(visited, {x, y}, direction(:left))
  #
  #       total = [up_visited, right_visited, down_visited, left_visited] |> Enum.count(& &1)
  #
  #       case total do
  #         0 ->
  #           grid |> Enum.at(y) |> Enum.at(x)
  #
  #         1 ->
  #           cond do
  #             up_visited -> "^"
  #             right_visited -> ">"
  #             down_visited -> "v"
  #             left_visited -> "<"
  #           end
  #
  #         _ ->
  #           "#{total}"
  #       end
  #     end)
  #   end)
  # end
end
