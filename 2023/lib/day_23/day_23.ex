defmodule Day23.Day23 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def part_a(grid) do
    grid
    |> IO.inspect(label: "grid")
    |> find_path({1, 0}, {length(grid |> Enum.at(0)) - 2, length(grid) - 1})
  end

  defp find_path(grid, pos, goal, visited \\ MapSet.new())

  defp find_path(_grid, pos, goal, visited) when pos == goal do
    (visited |> MapSet.size())
  end

  defp find_path(grid, pos, goal, visited) do
    next_positions =
      get_dirs_for_pos(grid, pos)
      |> Enum.map(&direction_to_coords/1)
      |> Enum.map(&move(pos, &1))
      |> Enum.filter(&is_valid_move?(grid, &1, visited))

    if Enum.empty?(next_positions) do
      0
    else
      next_positions
      |> Enum.map(&find_path(grid, &1, goal, visited |> MapSet.put(pos)))
      |> Enum.max()
    end
  end

  defp get_dirs_for_pos(grid, {x, y}) do
    tile = grid |> Enum.at(y) |> Enum.at(x)

    case tile do
      ">" -> [:right]
      "<" -> [:left]
      "^" -> [:up]
      "v" -> [:down]
      _ -> [:up, :down, :left, :right]
    end
  end

  defp direction_to_coords(direction) do
    case direction do
      :up -> {0, -1}
      :down -> {0, 1}
      :left -> {-1, 0}
      :right -> {1, 0}
    end
  end

  defp move({x, y}, {dx, dy}), do: {x + dx, y + dy}

  defp is_valid_move?(grid, {x, y}, visited) do
    in_bounds?(grid, {x, y}) && !is_wall?(grid, {x, y}) && !is_visited?(visited, {x, y})
  end

  defp in_bounds?(grid, {x, y}) do
    x >= 0 && x < grid |> Enum.at(0) |> Enum.count() && y >= 0 && y < grid |> Enum.count()
  end

  defp is_wall?(grid, {x, y}) do
    grid |> Enum.at(y) |> Enum.at(x) == "#"
  end

  defp is_visited?(visited, pos) do
    Enum.member?(visited, pos)
  end

  def part_b(input) do
    # Your code here
  end
end
