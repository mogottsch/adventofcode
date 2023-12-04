defmodule Mix.Tasks.Benchmark do
  use Mix.Task

  def run([]) do
    with {:ok, list} <- :application.get_key(:aoc, :modules) do
      list
      |> Enum.filter(&Regex.match?(~r/Day\d{2}\.Day\d{2}/, to_string(&1)))
      |> Enum.each(&benchmark(&1))
    end
  end

  defp benchmark(module_name) do
    IO.puts("Benchmarking #{module_name}...")

    day = String.slice(to_string(module_name), -2..-1)

    input_path = "lib/day_#{day}/input.txt"
    input = module_name.parse_file(input_path)

    Benchee.run(
      %{
        "#{module_name} - Part A" => fn ->
          module_name.part_a(input)
        end,
        "#{module_name} - Part B" => fn ->
          module_name.part_b(input)
        end,
        "#{module_name} - Parse" => fn ->
          module_name.parse_file(input_path)
        end
      },
      time: 1,
      warmup: 0.1
    )
    |> Benchee.collect()
    |> Benchee.statistics()
    |> Benchee.Formatter.output()
    |> format_as_markdown(day)
    |> write_to_readme(day)
  end

  defp format_as_markdown(%{scenarios: scenarios}, day) do
    [parse, part1, part2] =
      scenarios
      |> Enum.map(fn s -> s.run_time_data.statistics.median end)

    [parse, part1, part2, total] =
      [parse, part1, part2, parse + part1 + part2] |> Enum.map(&format_as_timestring/1)

    "| #{day} | #{parse} | #{part1} | #{part2} | #{total} |"
  end

  defp format_as_timestring(nanoseconds) do
    Number.SI.number_to_si(nanoseconds / 1_000_000_000, unit: "s", separator: " ", precision: 2)
    |> String.replace(" ns", " ns ⚪️")
    |> String.replace(" µs", " µs ⚪️")
    |> String.replace(" ms", " ms 🔵")
    |> String.replace(" s", " s 🔴")
  end

  # the readme contains the following:
  # <!-- BENCHMARKS_START -->
  # | day | parse | part a | part b | total |
  # |-----|-------|--------|--------|-------|
  # <!-- BENCHMARKS_END -->
  #
  # this function finds the row for the current day and replaces it with the new benchmark data
  # if the row doesn't exist, it will be appended to the end of the table
  # then it will sort the table by day
  defp write_to_readme(markdown, day) do
    readme_path = "README.md"
    readme = File.read!(readme_path)

    start_marker = "<!-- BENCHMARKS_START -->"
    end_marker = "<!-- BENCHMARKS_END -->"

    day_int = String.to_integer(day)

    header = "| day | parse | part a | part b | total |"
    header_underline = "|-----|-------|--------|--------|-------|"

    new_benchmark_table =
      readme
      |> String.split("\n")
      |> Enum.take_while(&(&1 != end_marker))
      |> Enum.drop_while(&(&1 != start_marker))
      |> Enum.drop(3)
      |> replace_if_exists(day, markdown, day_int)
      |> add_if_not_exists(day, markdown, day_int)
      |> sort_by_day()
      |> Enum.join("\n")

    new_benchmark_table = "#{header}\n#{header_underline}\n#{new_benchmark_table}"

    new_readme =
      Regex.replace(
        ~r/#{start_marker}.*?#{end_marker}/s,
        readme,
        "#{start_marker}\n#{new_benchmark_table}\n#{end_marker}"
      )

    File.write!(readme_path, new_readme)
  end

  defp replace_if_exists(lines, day, markdown, day_int) do
    Enum.map(lines, fn line ->
      if String.split(line, "|", trim: true)
         |> List.first()
         |> String.trim()
         |> String.to_integer() == day_int do
        markdown
      else
        line
      end
    end)
  end

  defp add_if_not_exists(lines, day, markdown, day_int) do
    if Enum.any?(lines, fn line ->
         String.split(line, "|", trim: true)
         |> List.first()
         |> String.trim()
         |> String.to_integer() == day_int
       end) do
      lines
    else
      lines ++ [markdown]
    end
  end

  defp sort_by_day(lines) do
    lines
    |> Enum.sort_by(fn line ->
      String.split(line, "|", trim: true)
      |> List.first()
      |> String.trim()
      |> String.to_integer()
    end)
  end
end
