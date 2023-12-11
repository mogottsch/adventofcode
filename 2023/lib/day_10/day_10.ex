defmodule Day10.Day10 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def part_a(grid) do
    grid
    |> find_start_position()
    |> find_cycles_in(grid)
    |> Enum.map(&Enum.count/1)
    |> Enum.max()
    |> then(&(&1 / 2))
  end

  defp find_start_position(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {col, col_index} ->
        case col do
          "S" -> {row_index, col_index}
          _ -> nil
        end
      end)
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> List.first()
  end

  defp find_cycles_in(start_position, grid) do
    start_position
    |> adjacent_positions()
    |> Enum.map(fn pos ->
      find_cycle(pos, grid, [start_position])
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp adjacent_positions({row, col}) do
    [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
  end

  defp find_cycle(pos, grid, visited) do
    if Enum.member?(visited, pos) do
      visited
    else
      next_pos = next_position(pos, List.first(visited), grid)

      if next_pos == nil or not in_bounds(next_pos, grid) do
        nil
      else
        find_cycle(next_pos, grid, [pos | visited])
      end
    end
  end

  defp next_position({row, col}, last_pos, grid) do
    case grid |> Enum.at(row) |> Enum.at(col) do
      "L" -> choose_other({{row - 1, col}, {row, col + 1}}, last_pos)
      "J" -> choose_other({{row - 1, col}, {row, col - 1}}, last_pos)
      "F" -> choose_other({{row + 1, col}, {row, col + 1}}, last_pos)
      "7" -> choose_other({{row + 1, col}, {row, col - 1}}, last_pos)
      "|" -> choose_other({{row - 1, col}, {row + 1, col}}, last_pos)
      "-" -> choose_other({{row, col + 1}, {row, col - 1}}, last_pos)
      "." -> nil
    end
  end

  defp in_bounds({row, col}, grid) do
    row >= 0 && row < Enum.count(grid) && col >= 0 && col < Enum.count(Enum.at(grid, 0))
  end

  defp touches_bounds({row, col}, grid) do
    row == 0 or row == Enum.count(grid) - 1 or col == 0 or col == Enum.count(Enum.at(grid, 0)) - 1
  end

  defp choose_other({pos1, pos2}, last_pos) do
    if pos1 == last_pos do
      pos2
    else
      pos1
    end
  end

  # ------------------------ PART B -------------------------------------------

  def part_b(grid) do
    start_position = find_start_position(grid)

    cycle =
      start_position
      |> find_cycles_in(grid)
      |> Enum.max_by(&Enum.count/1)

    grid = grid |> replace_start_position(cycle, start_position)

    [:left, :right]
    |> Enum.map(&get_ring(cycle, grid, &1))
    |> Enum.filter(fn ring -> Enum.all?(ring, &(not touches_bounds(&1, grid))) end)
    |> then(fn ring ->
      if Enum.count(ring) == 1 do
        ring
      else
        throw(
          "Neither ring touches the bounds, we need to explore before we can decide which one to use"
        )
      end
    end)
    |> List.first()
    |> explore_inner(cycle, grid)
    |> Enum.count()
  end

  defp replace_start_position(grid, cycle, start_position) do
    after_start = cycle |> Enum.at(0)
    before_start = cycle |> Enum.at(-2)
    start_pipe_symbol = pipe_symbol_from_arrangement(start_position, before_start, after_start)

    grid |> replace_at(start_position, start_pipe_symbol)
  end

  defp replace_at(grid, {to_replace_row, to_replace_col}, symbol) do
    Enum.with_index(grid, fn row, row_index ->
      Enum.with_index(row, fn col, col_index ->
        if row_index == to_replace_row and col_index == to_replace_col do
          symbol
        else
          col
        end
      end)
    end)
  end

  defp explore_inner(ring, cycle, grid) do
    ring
    |> Enum.reduce(MapSet.new(), fn pos, visited ->
      explore_inner_from(pos, visited, cycle, grid)
    end)
  end

  defp explore_inner_from(pos, visited, cycle, grid) do
    if Enum.member?(visited, pos) or Enum.member?(cycle, pos) or not in_bounds(pos, grid) do
      visited
    else
      visited = MapSet.put(visited, pos)

      [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
      |> Enum.reduce(visited, fn {row_offset, col_offset}, visited ->
        {row, col} = pos
        new_pos = {row + row_offset, col + col_offset}

        explore_inner_from(new_pos, visited, cycle, grid)
      end)
    end
  end

  # defp blank_grid_of_size(grid) do
  #   grid_x_size = Enum.count(Enum.at(grid, 0))
  #   grid_y_size = Enum.count(grid)
  #
  #   Enum.map(0..(grid_y_size - 1), fn _ ->
  #     Enum.map(0..(grid_x_size - 1), fn _ ->
  #       "."
  #     end)
  #   end)
  # end
  #
  # defp visualize_cycle(cycle, grid, symbol \\ "X") do
  #   grid_x_size = Enum.count(Enum.at(grid, 0))
  #   grid_y_size = Enum.count(grid)
  #
  #   Enum.map(0..(grid_y_size - 1), fn row ->
  #     Enum.map(0..(grid_x_size - 1), fn col ->
  #       if Enum.member?(cycle, {row, col}) do
  #         symbol
  #       else
  #         Enum.at(grid, row) |> Enum.at(col)
  #       end
  #     end)
  #     |> Enum.join()
  #   end)
  #   |> Enum.join("\n")
  # end

  defp get_ring(cycle, grid, direction) do
    [List.last(cycle) | cycle]
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [prev, next] -> get_ring_neighbors(next, prev, grid, direction) end)
    |> List.flatten()
    |> Enum.filter(&in_bounds(&1, grid))
    |> Enum.filter(fn pos -> not Enum.member?(cycle, pos) end)
    |> Enum.uniq()
  end

  defp get_ring_neighbors({row, col}, {prev_row, prev_col}, grid, direction) do
    symbol = grid |> Enum.at(row) |> Enum.at(col)

    relative_position = relative_position({prev_row - row, prev_col - col})

    get_ring_neighbors_for_symbol({row, col}, symbol, relative_position, direction)
  end

  def get_ring_neighbors_for_symbol({row, col}, symbol, relative_position, :right) do
    case {symbol, relative_position} do
      # left and below
      {"L", :up} -> [{row + 1, col}, {row, col - 1}]
      # nothing
      {"L", :right} -> []
      # nothing
      {"J", :up} -> []
      # below and right
      {"J", :left} -> [{row + 1, col}, {row, col + 1}]
      # nothing
      {"F", :down} -> []
      # above and left
      {"F", :right} -> [{row - 1, col}, {row, col - 1}]
      # right and above
      {"7", :down} -> [{row - 1, col}, {row, col + 1}]
      # nothing
      {"7", :left} -> []
      # left
      {"|", :up} -> [{row, col - 1}]
      # right
      {"|", :down} -> [{row, col + 1}]
      # below
      {"-", :left} -> [{row + 1, col}]
      # above
      {"-", :right} -> [{row - 1, col}]
      _ -> throw("Invalid symbol combination #{symbol} #{relative_position}")
    end
  end

  def get_ring_neighbors_for_symbol({row, col}, symbol, relative_position, :left) do
    case {symbol, relative_position} do
      # left and below
      {"L", :right} -> [{row + 1, col}, {row, col - 1}]
      # nothing
      {"L", :up} -> []
      # nothing
      {"J", :left} -> []
      # below and right
      {"J", :up} -> [{row + 1, col}, {row, col + 1}]
      # nothing
      {"F", :right} -> []
      # above and left
      {"F", :down} -> [{row - 1, col}, {row, col - 1}]
      # right and above
      {"7", :left} -> [{row - 1, col}, {row, col + 1}]
      # nothing
      {"7", :down} -> []
      # left
      {"|", :down} -> [{row, col - 1}]
      # right
      {"|", :up} -> [{row, col + 1}]
      # below
      {"-", :right} -> [{row + 1, col}]
      # above
      {"-", :left} -> [{row - 1, col}]
      _ -> throw("Invalid symbol combination #{symbol} #{relative_position}")
    end
  end

  defp pipe_symbol_from_arrangement(start_position, before_start, after_start) do
    [before_start, after_start]
    |> normalize_positions_to(start_position)
    |> Enum.map(fn pos -> relative_position(pos) end)
    |> pipe_symbol_from_relative_positions()
  end

  defp normalize_positions_to(positions, anchor) do
    {anchor_x, anchor_y} = anchor

    Enum.map(positions, fn {x, y} -> {x - anchor_x, y - anchor_y} end)
  end

  defp relative_position(pos) do
    case pos do
      {0, 1} -> :right
      {0, -1} -> :left
      {1, 0} -> :down
      {-1, 0} -> :up
    end
  end

  defp pipe_symbol_from_relative_positions([pos1, pos2]) do
    case {pos1, pos2} do
      {:up, :down} -> "|"
      {:down, :up} -> "|"
      {:left, :right} -> "-"
      {:right, :left} -> "-"
      {:up, :right} -> "L"
      {:right, :up} -> "L"
      {:left, :up} -> "J"
      {:up, :left} -> "J"
      {:down, :right} -> "F"
      {:right, :down} -> "F"
      {:left, :down} -> "7"
      {:down, :left} -> "7"
    end
  end
end
