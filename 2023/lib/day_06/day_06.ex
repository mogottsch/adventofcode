defmodule Day06.Day06 do
  def part_a(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, ":", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
    |> Enum.map(fn {race_time, distance} ->
      min_valid = 1 / 2 * (race_time - :math.sqrt(race_time * race_time - 4 * distance))
      max_valid = 1 / 2 * (race_time + :math.sqrt(race_time * race_time - 4 * distance))

      min_valid =
        if min_valid == ceil(min_valid) do
          min_valid + 1
        else
          ceil(min_valid)
        end

      max_valid =
        if max_valid == floor(max_valid) do
          max_valid - 1
        else
          floor(max_valid)
        end

      max_valid - min_valid + 1
    end)
    |> Enum.product()
  end

  def part_b(input) do
    input
    |> Enum.map(fn line ->
      String.split(line, ":", trim: true)
      |> List.last()
      |> String.replace(" ", "")
      |> String.to_integer()
    end)
    |> List.to_tuple()
    |> then(fn {race_time, distance} ->
      min_valid = 1 / 2 * (race_time - :math.sqrt(race_time * race_time - 4 * distance))
      max_valid = 1 / 2 * (race_time + :math.sqrt(race_time * race_time - 4 * distance))

      min_valid =
        if min_valid == ceil(min_valid) do
          min_valid + 1
        else
          ceil(min_valid)
        end

      max_valid =
        if max_valid == floor(max_valid) do
          max_valid - 1
        else
          floor(max_valid)
        end

      {1 / 2 * (race_time - :math.sqrt(race_time * race_time - 4 * distance)),
       1 / 2 * (race_time + :math.sqrt(race_time * race_time - 4 * distance))}

      max_valid - min_valid + 1
    end)
  end

  def parse_file(file_path) do
    File.read!(file_path)
    |> String.split("\n", trim: true)
  end
end
