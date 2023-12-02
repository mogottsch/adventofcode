defmodule A do
  @bag_contents %{
    "red" => 12,
    "green" => 13,
    "blue" => 14
  }

  def parse_file(file_path) do
    file_path
    |> read_lines
    |> Enum.map(&parse_game/1)
    |> Enum.filter(&is_game_valid/1)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  defp read_lines(file_path) do
    {:ok, file} = File.read(file_path)
    String.split(file, "\n", trim: true)
  end

  defp parse_game(line) do
    [game_id | game_info] = line |> String.split(": ")

    game_id = game_id |> String.split(" ") |> List.last() |> Integer.parse() |> elem(0)

    takes =
      game_info
      |> List.first()
      |> String.split("; ")
      |> Enum.map(&String.split(&1, ", "))
      |> Enum.map(fn take ->
        take
        |> Enum.map(
          &(String.split(&1, " ")
            |> List.to_tuple()
            |> then(fn {num, color} -> {color, String.to_integer(num)} end))
        )
      end)

    {game_id, takes}
  end

  defp is_game_valid({_game_id, takes}) do
    takes |> Enum.map(&is_take_valid/1) |> Enum.all?(& &1)
  end

  defp is_take_valid(take) do
    take |> Enum.map(&is_color_valid/1) |> Enum.all?(& &1)
  end

  defp is_color_valid({color, num}) do
    num <= @bag_contents[color]
  end
end

IO.puts(A.parse_file("./input.txt"))
