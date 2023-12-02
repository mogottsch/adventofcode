defmodule B do
  def part_b(file_path) do
    file_path
    |> read_lines
    |> Enum.map(fn line ->
      line
      |> parse_game()
      |> get_minimum_config()
      |> Map.values()
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  defp read_lines(file_path) do
    {:ok, file} = File.read(file_path)
    String.split(file, "\n", trim: true)
  end

  defp parse_game(line) do
    [game_id | game_info] = String.split(line, ": ")
    {parse_game_id(game_id), List.first(game_info) |> parse_game_info()}
  end

  defp parse_game_id(game_id_part) do
    game_id_part
    |> String.split(" ")
    |> List.last()
    |> String.to_integer()
  end

  defp parse_game_info(game_info) do
    game_info
    |> String.split("; ")
    |> Enum.map(&parse_take/1)
  end

  defp parse_take(take) do
    take
    |> String.split(", ")
    |> Enum.map(&parse_color_and_number/1)
    |> Map.new()
  end

  defp parse_color_and_number(pair) do
    [num_str, color] = String.split(pair, " ")
    {color, String.to_integer(num_str)}
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
    Map.merge(config, take, fn _key, old_val, new_val -> max(old_val, new_val) end)
  end
end

IO.inspect(B.part_b("./input.txt"))
