defmodule B do
  def parse_file(file_path) do
    file_path
    |> read_lines
    |> Enum.map(&parse_game/1)
    |> Enum.map(&get_minimum_config/1)
    |> Enum.map(&Map.values/1)
    |> Enum.map(&Enum.product/1)
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
        |> Map.new()
      end)

    {game_id, takes}
  end

  defp get_minimum_config({_game_id, takes}) do
    initial_config = %{
      "red" => 0,
      "green" => 0,
      "blue" => 0
    }

    takes |> Enum.reduce(initial_config, &update_minimum_config_if_necessary/2)
  end

  defp update_minimum_config_if_necessary(take, config) do
    config
    |> Map.to_list()
    |> Enum.map(fn {key, value} -> {key, max(value, Map.get(take, key, 0))} end)
    |> Map.new()
  end
end

IO.inspect(B.parse_file("./input.txt"))
