is_number = fn char ->
  case Integer.parse(char) do
    {_, ""} -> true
    _ -> false
  end
end

find_first_digit = fn string -> Enum.find(String.graphemes(string), is_number) end
find_last_digit = fn string -> Enum.find(String.graphemes(String.reverse(string)), is_number) end

{:ok, file} = File.read("./input.txt")
lines = String.split(file, "\n") |> Enum.filter(fn line -> line != "" end)

total =
  Enum.zip(
    Enum.map(lines, find_first_digit),
    Enum.map(lines, find_last_digit)
  )
  |> Enum.map(fn {head, tail} -> head <> tail end)
  |> Enum.map(fn string -> String.to_integer(string) end)
  |> Enum.sum()

IO.puts(total)

