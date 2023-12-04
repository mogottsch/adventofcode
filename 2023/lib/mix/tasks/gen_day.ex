defmodule Mix.Tasks.GenDay do
  use Mix.Task

  @shortdoc "Creates new files for a given Advent of Code day"

  def run([day]) do
    day = String.pad_leading(day, 2, "0")
    dir_path = "lib/day_#{day}"
    file_path = "#{dir_path}/day_#{day}.ex"

    unless File.exists?(file_path) do
      File.mkdir_p!(dir_path)
      File.write!(file_path, day_module_template(day))
      File.write!(Path.join(dir_path, "example.txt"), "")
      File.write!(Path.join(dir_path, "input.txt"), "")
      IO.puts("Created Advent of Code files for day #{day}")
    else
      IO.puts("Files for day #{day} already exist")
    end
  end

  defp day_module_template(day) do
    """
    defmodule Day#{day}.Day#{day} do
      def part_a(input) do
        # Your code here
      end

      def part_b(input) do
        # Your code here
      end

      def parse_file(file_path) do
        # Your code here
      end
    end
    """
  end
end
