defmodule Day05.Day05 do
  def part_a(input) do
    {seeds, maps} = input

    seeds
    |> Enum.map(&chain_through_maps(&1, maps))
    |> Enum.min()
  end

  def part_b(input) do
    {seeds, maps} = input

    ranges = seeds |> Enum.chunk_every(2) |> Enum.map(&List.to_tuple/1)

    maps
    |> Enum.reduce(ranges, fn map, ranges ->
      transform_ranges(ranges, map)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  # takes ranges of form [[start, offset], ...]
  # and takes a map of form [[dest_start, source_start, offset], ...]
  # and returns a map of form [[dest_start, offset], ...]
  defp transform_ranges(ranges, map) do
    # IO.inspect(ranges, charlists: :as_lists)
    # IO.inspect(map, charlists: :as_lists)

    map
    |> Enum.reduce({ranges, []}, fn {dest_start, source_start, offset},
                                    {ranges, destination_ranges} ->
      {remaining_ranges, new_destination_ranges} =
        transform_ranges_for_single_map(ranges, dest_start, source_start, offset)

      {remaining_ranges, new_destination_ranges ++ destination_ranges}
    end)
    |> then(fn {ranges, destination_ranges} ->
      ranges ++ destination_ranges
    end)
  end

  defp transform_ranges_for_single_map(ranges, dest_start, source_start, offset) do
    # IO.inspect(ranges, charlists: :as_lists, label: "input: ranges")
    # IO.inspect({dest_start, source_start, offset}, label: "input: map")

    ranges
    |> Enum.map(fn {r_start, r_offset} ->
      r_end = r_start + r_offset - 1
      source_end = source_start + offset - 1

      cond do
        # range is completely before or completly after map
        r_end < source_start or r_start > source_end ->
          {[{r_start, r_offset}], nil}

        # range is completely inside map
        r_start >= source_start and r_end <= source_end ->
          {[], {r_start + (dest_start - source_start), r_offset}}

        # range overlaps with start of map
        r_start < source_start and r_end <= source_end ->
          {[{r_start, source_start - r_start}], {dest_start, r_end - source_start + 1}}

        # range overlaps with end of map
        r_start >= source_start and r_end > source_end ->
          {[{r_start, source_end - r_start + 1}],
           {dest_start + (r_start - source_start), r_end - source_end + 1}}

        # range completely overlaps map
        r_start < source_start and r_end > source_end ->
          {[{r_start, source_start - r_start}, {source_end + 1, r_end - source_end}],
           {dest_start, offset}}
      end
    end)
    |> Enum.reduce({[], []}, fn
      {new_ranges, new_destination_range}, {ranges, destination_ranges} ->
        new_destination_ranges =
          if new_destination_range == nil do
            destination_ranges
          else
            [new_destination_range | destination_ranges]
          end

        {new_ranges ++ ranges, new_destination_ranges}
    end)

    # |> IO.inspect(charlists: :as_lists)
  end

  defp chain_through_maps(seed, maps) do
    maps
    |> Enum.reduce(seed, fn ranges, seed ->
      ranges
      |> Enum.reduce({seed, false}, fn range, acc ->
        {seed, found} = acc

        if found do
          acc
        else
          {dest_min, min, offset} = range
          max = min + offset - 1

          if seed >= min and seed <= max do
            dest = dest_min + (seed - min)
            {dest, true}
          else
            acc
          end
        end
      end)
      |> elem(0)
    end)
  end

  def parse_file(file_path) do
    {:ok, file} = File.read(file_path)

    {_, seeds, maps} =
      String.split(file, "\n", trim: true)
      |> Enum.reduce({:seeds, [], []}, fn line, acc ->
        {state, seeds, maps} = acc

        case state do
          :seeds ->
            parse_seeds(line)

          :map ->
            parse_range(line, seeds, maps)
        end
      end)

    {seeds, maps |> Enum.reverse()}
  end

  defp parse_seeds(line) do
    seeds =
      line
      |> String.split(": ", trim: true)
      |> List.last()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    {:map, seeds, []}
  end

  defp parse_range(line, seeds, maps) do
    if String.contains?(line, ":") do
      {:map, seeds, [[] | maps]}
    else
      range =
        line
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()

      [old_ranges | _] = maps
      new_ranges = old_ranges ++ [range]
      {:map, seeds, [new_ranges | Enum.drop(maps, 1)]}
    end
  end
end
