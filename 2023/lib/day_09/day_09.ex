defmodule Day09.Day09 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def part_a(serieses) do
    serieses |> Enum.map(&extrapolate(&1, :forward)) |> Enum.sum()

  end
  def part_b(serieses) do
    serieses |> Enum.map(&extrapolate(&1, :backward)) |> Enum.sum()
  end

  defp extrapolate(series, :forward) do
    [List.last(series) | derive_until_constant(series, :forward)]
    |> Enum.sum()
  end

  defp extrapolate(series, :backward) do
    [List.first(series) | derive_until_constant(series, :backward)]
    |> Enum.reverse()
    |> Enum.reduce(0, fn x, acc -> x - acc end)
  end

  defp derive_until_constant(series, direction) do
    series
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
    |> then(fn new_series ->
      new_element =
        case direction do
          :forward -> List.last(new_series)
          :backward -> List.first(new_series)
        end

      if Enum.all?(new_series, &(&1 == 0)) do
        []
      else
        [new_element | derive_until_constant(new_series, direction)]
      end
    end)
  end

end
