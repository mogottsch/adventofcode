defmodule Day14.Day14 do
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
    grid |> rotate_right() |> fall_right() |> rotate_left() |> calculate_load()
  end

  defp rotate_right(grid) do
    grid |> Enum.zip_with(&Enum.reverse/1)
  end

  defp rotate_left(grid) do
    grid |> Enum.zip_with(&Function.identity/1) |> Enum.reverse()
  end

  defp fall_right(grid) do
    grid
    |> Enum.map(fn line ->
      line
      |> Enum.join()
      |> String.split("#")
      |> Enum.map(fn group ->
        group |> sort_string()
      end)
      |> Enum.join("#")
      |> String.graphemes()
    end)
  end

  defp sort_string(group) do
    group |> String.graphemes() |> Enum.sort() |> Enum.join()
  end

  defp calculate_load(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      (line |> Enum.frequencies() |> Map.get("O", 0)) * (length(grid) - index)
    end)
    |> Enum.sum()
  end

  def part_b(grid) do
    {first, second} = grid |> find_repetition()

    repetition_length = second - first

    n_cycles = 1_000_000_000

    repeat = trunc(:math.floor((n_cycles - first) / repetition_length))
    same_as_first = repetition_length * repeat + first
    remaining_to_run = n_cycles - same_as_first
    grid |> run_cycles(first + remaining_to_run) |> calculate_load()
  end

  defp find_repetition(grid, seen \\ %{}, i \\ 0)

  defp find_repetition(grid, seen, i) when i == 0 do
    find_repetition(grid, Map.put(seen, grid, i), i + 1)
  end

  defp find_repetition(grid, seen, i) do
    new_grid = grid |> run_cycles(1)

    if Map.has_key?(seen, new_grid) do
      {Map.get(seen, new_grid), i}
    else
      find_repetition(new_grid, Map.put(seen, new_grid, i), i + 1)
    end
  end

  defp run_cycles(grid, 0) do
    grid
  end

  defp run_cycles(grid, n) do
    grid
    |> rotate_right_and_fall(4)
    |> run_cycles(n - 1)
  end

  defp rotate_right_and_fall(grid, 0) do
    grid
  end

  defp rotate_right_and_fall(grid, n) do
    grid |> rotate_right() |> fall_right() |> rotate_right_and_fall(n - 1)
  end
end
