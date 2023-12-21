defmodule Day21.Day21 do
  alias Day_12.Cache, as: Cache

  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> extract_and_replace_start_position()
  end

  defp extract_and_replace_start_position(grid) do
    {grid |> find_start_position(), grid |> replace_start_position()}
  end

  defp find_start_position(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {row, rowIndex} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {char, colIndex} ->
        if char == "S" do
          {rowIndex, colIndex}
        end
      end)
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> List.first()
  end

  defp replace_start_position(grid) do
    grid
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn char ->
        if char == "S" do
          "."
        else
          char
        end
      end)
    end)
  end

  def part_a({start, grid}) do
    Cache.setup()
    walk_steps(start, grid, 64) |> MapSet.size()
  end

  defp walk_steps(start, _grid, 0), do: MapSet.new([start])

  defp walk_steps(start, grid, steps) do
    case Cache.get({start, steps}) do
      nil -> calculate_steps(start, grid, steps)
      cache_value -> cache_value
    end
  end

  defp calculate_steps(start, grid, steps) do
    [:up, :down, :left, :right]
    |> Enum.map(fn direction ->
      new_pos = direction |> direction() |> take_step(start)

      if new_pos |> is_valid_position(grid) do
        walk_steps(new_pos, grid, steps - 1)
      else
        MapSet.new()
      end
    end)
    |> Enum.reduce(MapSet.new(), fn set, acc ->
      MapSet.union(set, acc)
    end)
    |> cache_value({start, steps})
  end

  defp cache_value(value, {start, steps}) do
    Cache.put({start, steps}, value)
    value
  end

  defp direction(:up), do: {0, -1}
  defp direction(:down), do: {0, 1}
  defp direction(:left), do: {-1, 0}
  defp direction(:right), do: {1, 0}

  defp take_step({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  defp is_valid_position(pos, grid) do
    is_in_bounds(pos, grid) && is_not_on_rock(pos, grid)
  end

  defp is_in_bounds({x, y}, grid) do
    x >= 0 && x < grid |> Enum.count() && y >= 0 && y < grid |> List.first() |> Enum.count()
  end

  defp is_not_on_rock({x, y}, grid) do
    grid
    |> Enum.at(x)
    |> Enum.at(y)
    |> then(fn char ->
      char != "#"
    end)
  end

  def part_b(input) do
    # Your code here
  end
end
