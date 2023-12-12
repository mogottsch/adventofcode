defmodule Day12.Day12 do
  use Nebulex.Caching

  alias Day_12.Cache, as: Cache

  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(" ")
    |> List.to_tuple()
    |> then(fn {records, code} ->
      {
        records |> String.split("", trim: true),
        code |> String.split(",") |> Enum.map(&String.to_integer/1)
      }
    end)
  end

  def part_a(input) do
    Cache.setup()

    input
    |> Enum.map(fn {line, code} ->
      line
      |> n_valid_arrangements(code)
    end)
    |> Enum.sum()
  end

  defp n_valid_arrangements_cached(line, code, current_group_size \\ 0) do
    cached_value = Cache.get({line, code, current_group_size})

    if cached_value != nil do
      cached_value
    else
      value = n_valid_arrangements(line, code, current_group_size)
      Cache.put({line, code, current_group_size}, value)
      value
    end
  end

  defp n_valid_arrangements(line, code, current_group_size \\ 0)

  defp n_valid_arrangements(line, code, current_group_size) when length(line) == 0 do
    if (current_group_size == 0 and code == []) or
         (length(code) == 1 and code |> Enum.at(0) == current_group_size) do
      1
    else
      0
    end
  end

  defp n_valid_arrangements(line, code, current_group_size) do
    [first_char | rest] = line

    case first_char do
      "#" -> handle_hash(rest, code, current_group_size)
      "." -> handle_dot(rest, code, current_group_size)
      "?" -> handle_unknown(rest, code, current_group_size)
    end
  end

  defp handle_dot(rest, code, current_group_size) do
    if current_group_size == 0 do
      n_valid_arrangements_cached(rest, code, current_group_size)
    else
      handle_dot_new_group(rest, code, current_group_size)
    end
  end

  defp handle_dot_new_group(rest, code, current_group_size) do
    if code == [] do
      0
    else
      [next_expected_group_size | rest_code] = code

      if current_group_size == next_expected_group_size do
        n_valid_arrangements_cached(rest, rest_code, 0)
      else
        0
      end
    end
  end

  defp handle_hash(rest, code, current_group_size) do
    n_valid_arrangements_cached(rest, code, current_group_size + 1)
  end

  defp handle_unknown(rest, code, current_group_size) do
    handle_hash(rest, code, current_group_size) +
      handle_dot(rest, code, current_group_size)
  end

  def part_b(input) do
    Cache.setup()

    input
    |> Enum.map(fn {line, code} ->
      {
        line |> unfold("?"),
        code |> unfold(nil)
      }
    end)
    |> Enum.map(fn {line, code} ->

      line
      |> n_valid_arrangements(code)
    end)
    |> Enum.sum()
  end

  defp unfold(code, nil) do
    (code |> List.duplicate(4) |> List.flatten()) ++ code
  end

  defp unfold(line, char) do
    ((line ++ [char]) |> List.duplicate(4) |> List.flatten()) ++ line
  end
end
