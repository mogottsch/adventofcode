defmodule Day04.Day04 do
  def part_a(input) do
    input
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  defp score(size) when size == 0, do: 0
  defp score(size), do: 2 ** (size - 1)

  def part_b(input) do
    input
    |> Enum.with_index()
    |> then(&{&1, &1 |> length |> create_one_map})
    |> then(fn {win_map, one_map} ->
      win_map
      |> Enum.reduce(one_map, fn {wins, i}, acc ->
        acc |> update_map_according_to_wins(wins, i)
      end)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  defp update_map_according_to_wins(acc, wins, curr_index) do
    if wins == 0 do
      acc
    else
      current_val = acc |> Map.get(curr_index)

      1..wins
      |> Enum.reduce(acc, fn i, acc ->
        acc
        |> Map.update!(i + curr_index, &(&1 + current_val))
      end)
    end
  end

  defp create_one_map(size) do
    0..(size - 1) |> Enum.map(&{&1, 1}) |> Map.new()
  end

  def parse_file(file_path) do
    {:ok, file} = File.read(file_path)

    String.split(file, "\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(fn {winning_numbers, tickets} ->
      winning_numbers
      |> MapSet.intersection(tickets)
      |> MapSet.size()
    end)
  end

  defp parse_line(line) do
    String.split(line, ": ", trim: true)
    |> List.last()
    |> String.split(" | ", trim: true)
    |> Enum.map(&(String.split(&1, " ", trim: true) |> MapSet.new()))
    |> List.to_tuple()
  end
end
