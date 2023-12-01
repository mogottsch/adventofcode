defmodule StringHelpers do
  def find_substring_position(string, substring, :first) do
    string
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.find_value(fn {_, index} ->
      if String.starts_with?(String.slice(string, index, String.length(substring)), substring) do
        index
      end
    end)
  end

  def find_substring_position(string, substring, :last) do
    string
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reverse()
    |> Enum.find_value(fn {_, index} ->
      if String.ends_with?(String.slice(string, index, String.length(substring)), substring) do
        index
      end
    end)
  end
end

defmodule B do
  @digit_map %{
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9
  }

  def parse_file(file_path) do
    lines = file_path |> read_lines

    Enum.zip(
      Enum.map(lines, &find_first_digit/1),
      Enum.map(lines, &find_last_digit/1)
    )
    |> Enum.map(fn {first, last} -> first <> last end)
    |> Enum.map(fn string -> String.to_integer(string) end)
    |> Enum.sum()
  end

  defp read_lines(file_path) do
    {:ok, file} = File.read(file_path)
    String.split(file, "\n") |> Enum.filter(&(&1 != ""))
  end

  defp find_first_digit(string) do
    find_digit(string, :first)
  end

  defp find_last_digit(string) do
    find_digit(string, :last)
  end

  defp find_digit(string, position_type) do
    digits =
      (Map.values(@digit_map) ++ Map.keys(@digit_map))
      |> Enum.map(&"#{&1}")

    Enum.zip(
      digits,
      digits
      |> Enum.map(&StringHelpers.find_substring_position(string, &1, position_type))
    )
    |> Enum.filter(fn {_, position} -> position != nil end)
    |> Enum.sort_by(fn {_, position} -> position end)
    |> get_first_or_last(position_type)
    |> elem(0)
    |> parse_digit_if_necessary()
    |> Integer.to_string()
  end

  defp get_first_or_last(list, position) do
    if position === :first do
      List.first(list)
    else
      List.last(list)
    end
  end

  defp parse_digit_if_necessary(str_digit) do
    case Integer.parse(str_digit) do
      {integer, ""} ->
        integer

      :error ->
        case Map.get(@digit_map, str_digit) do
          nil ->
            raise ArgumentError, message: "str_digit '#{str_digit}' is not in digit_map"

          value ->
            value
        end
    end
  end
end

total = B.parse_file("./input.txt")
IO.puts(total)
