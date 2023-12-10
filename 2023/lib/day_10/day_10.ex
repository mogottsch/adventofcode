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
    |> find_cycles_from(grid)
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

  defp find_cycles_from(start_position, grid) do
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

  defp choose_other({pos1, pos2}, last_pos) do
    if pos1 == last_pos do
      pos2
    else
      pos1
    end
  end

  def part_b(grid) do
    # Your code here
  end
end
