defmodule Day12.Day12 do
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
    input
    |> Enum.map(fn {line, code} ->
      line
      |> count_unknowns()
      |> generate_samples()
      |> Enum.map(&String.split(&1, "", trim: true))
      |> fill_in_samples(line)
      |> Enum.filter(fn line -> is_valid(line, code) end)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def count_unknowns(line) do
    line
    |> Enum.frequencies()
    |> Map.get("?", 0)
  end

  # generate a list of all possible instances
  # an instance is of length n_unknowns and contains only '#' and '.'
  def generate_samples(n_unknowns) when n_unknowns > 0 do
    generate_samples(n_unknowns, ["#", "."], [])
  end

  defp generate_samples(0, _characters, acc), do: acc

  defp generate_samples(n, characters, acc) when n > 0 do
    if acc == [] do
      # Initial call, start with the characters
      generate_samples(n - 1, characters, characters)
    else
      # Generate combinations by appending each character to each accumulated string
      extended = for prefix <- acc, char <- characters, do: prefix <> char
      generate_samples(n - 1, characters, extended)
    end
  end

  def fill_in_samples(samples, line) do
    samples
    |> Enum.map(fn sample ->
      line
      |> Enum.reduce({sample, []}, fn char, {sample, line} ->
        if char == "?" do
          {next_char, sample} = List.pop_at(sample, 0)
          {sample, [next_char | line]}
        else
          {sample, [char | line]}
        end
      end)
      |> elem(1)
      |> Enum.reverse()
    end)
  end

  # checks whether the groups of consecutive '#'s in the line
  # match the code
  defp is_valid(line, code) do
    line
    |> Enum.with_index()
    |> Enum.reduce({0, []}, fn {char, index}, {current_group_size, group_sizes} ->
      is_last_char = index == length(line) - 1

      current_group_size =
        if char == "#" do
          current_group_size + 1
        else
          current_group_size
        end

      if (char == "." or is_last_char) and current_group_size > 0 do
        {0, [current_group_size | group_sizes]}
      else
        {current_group_size, group_sizes}
      end
    end)
    |> elem(1)
    |> Enum.reverse()
    |> then(fn lengths ->
      lengths == code
    end)
  end

  def part_b(input) do
    # Your code here
  end
end
