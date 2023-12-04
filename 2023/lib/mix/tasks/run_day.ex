defmodule Mix.Tasks.RunDay do
  use Mix.Task

  @shortdoc "Runs a specified part of the Advent of Code for a given day"

  def run([day_str, part, file_type]) do
    day = String.pad_leading(day_str, 2, "0")
    module_name = String.to_atom("Elixir.Day#{day}.Day#{day}")
    file_path = "lib/day_#{day}/#{file_type}.txt"

    if File.exists?(file_path) do
      input = module_name.parse_file(file_path)
      result = call_part_function(module_name, part, input)
      IO.puts("Result for Day #{day} Part #{part}: #{result}")
    else
      IO.puts("File not found: #{file_path}")
    end
  end

  defp call_part_function(module_name, "a", input) do
    module_name.part_a(input)
  end

  defp call_part_function(module_name, "b", input) do
    module_name.part_b(input)
  end
end
