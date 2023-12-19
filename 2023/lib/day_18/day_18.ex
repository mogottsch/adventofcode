# this is code is the result of 5 hours desperate debugging in the evening
# it works, but please don't judge me :(

defmodule Day18.Day18 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split(" ", trim: true)
    |> List.to_tuple()
    |> then(fn {dir, length, color} ->
      {
        parse_direction(dir),
        String.to_integer(length),
        color
      }
    end)
  end

  defp parse_direction(dir) do
    case dir do
      "R" -> :right
      "L" -> :left
      "U" -> :up
      "D" -> :down
    end
  end

  def part_a(input) do
    input =
      input
      |> Enum.map(fn {dir, length, _} ->
        {dir, length}
      end)

    {bbox, origin} =
      input
      |> get_shape()
      |> normalize_to_origin()

    input |> draw(bbox |> make_canvas(), origin) |> to_file("drawing.txt")

    input
    |> get_lines(origin)
    |> filter_lines()
    |> count_area_by_lines()
  end

  defp get_shape(input) do
    input
    |> Enum.reduce(
      {{0, 0}, {0, 0}, {0, 0}},
      fn {dir, length}, {{x, y}, {min_x, min_y}, {max_x, max_y}} ->
        {x, y} =
          case dir do
            :right -> {x + length, y}
            :left -> {x - length, y}
            :up -> {x, y - length}
            :down -> {x, y + length}
          end

        {{x, y}, {max(min_x, x), max(min_y, y)}, {min(max_x, x), min(max_y, y)}}
      end
    )
    |> then(fn {_, max, min} ->
      {max, min}
    end)
  end

  defp normalize_to_origin({{max_x, max_y}, {min_x, min_y}}) do
    {{max_x - min_x, max_y - min_y}, {-min_x, -min_y}}
  end

  defp make_canvas({width, height}) do
    Enum.map(0..height, fn _ ->
      Enum.map(0..width, fn _ ->
        "."
      end)
    end)
  end

  defp draw(instructions, canvas, origin) do
    instructions
    |> Enum.reduce(
      {origin, canvas},
      fn {dir, length}, {{x, y}, canvas} ->
        {new_x, new_y} =
          case dir do
            :right -> {x + length, y}
            :left -> {x - length, y}
            :up -> {x, y - length}
            :down -> {x, y + length}
          end

        left = min(x, new_x)
        right = max(x, new_x)
        top = min(y, new_y)
        bottom = max(y, new_y)

        canvas =
          canvas
          |> Enum.with_index()
          |> Enum.map(fn {row, row_index} ->
            row
            |> Enum.with_index()
            |> Enum.map(fn {el, col_index} ->
              if col_index >= left && col_index <= right &&
                   row_index >= top && row_index <= bottom do
                "#"
              else
                el
              end
            end)
          end)

        {{new_x, new_y}, canvas}
      end
    )
    |> elem(1)
  end

  def count_area(map) do
    (map ++ [Enum.at(map, -2)])
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [row, row_below] ->
      count_with_inside(row, row_below)
    end)
    |> Enum.sum()
  end

  defp count_with_inside(row, row_below) do
    row
    |> Enum.zip(row_below)
    |> Enum.reduce({0, 0}, fn {char, char_below}, {edge_count, count} ->
      case {char, char_below} do
        {"#", "."} -> {edge_count, count + 1}
        {"#", "#"} -> {edge_count + 1, count + 1}
        {".", _} -> {edge_count, count + rem(edge_count, 2)}
        _ -> throw("Invalid character")
      end
    end)
    |> elem(1)
  end

  def part_b(input) do
    {_bbox, origin} =
      input
      |> Enum.map(&parse_line_b/1)
      |> get_shape()
      |> normalize_to_origin()

    input
    |> Enum.map(&parse_line_b/1)
    |> get_lines(origin)
    |> filter_lines()
    |> count_area_by_lines()

    # input |> draw(bbox |> make_canvas(), origin) |> count_area()
  end

  defp parse_line_b({_dir, _length, color}) do
    color
    |> String.slice(2..-2)
    |> String.split_at(5)
    |> then(fn {hexa_length, dir_code} ->
      {
        parse_direction_b(dir_code),
        Integer.parse(hexa_length, 16) |> elem(0)
      }
    end)
  end

  defp parse_direction_b(dir) do
    case dir do
      "0" -> :right
      "1" -> :down
      "2" -> :left
      "3" -> :up
    end
  end

  defp get_lines(instructions, origin) do
    instructions
    |> Enum.reduce(
      {origin, Map.new(), Map.new()},
      fn {dir, length}, {{x, y}, v_line_map, h_line_map} ->
        {new_x, new_y} =
          case dir do
            :right -> {x + length, y}
            :left -> {x - length, y}
            :up -> {x, y - length}
            :down -> {x, y + length}
          end

        case dir do
          dir when dir in [:right, :left] ->
            left = min(x, new_x)
            right = max(x, new_x)

            new_h_line_map =
              h_line_map
              |> Map.update(y, [{left, right}], fn line ->
                [{left, right} | line]
              end)

            {{new_x, new_y}, v_line_map, new_h_line_map}

          dir when dir in [:up, :down] ->
            top = min(y, new_y)
            bottom = max(y, new_y)

            new_v_line_map =
              top..bottom
              |> Enum.reduce(v_line_map, fn y, v_line_map ->
                v_line_map
                |> Map.update(y, [x], fn line ->
                  [x | line]
                end)
              end)

            {{new_x, new_y}, new_v_line_map, h_line_map}

          _ ->
            throw("Invalid direction")
        end
      end
    )
    |> then(fn {_, v_line_map, h_line_map} ->
      {sort_map_values(v_line_map), h_line_map}
    end)
  end

  # retrieves a map where the values are lists
  # returns a map where the lists in the values are sorted
  defp sort_map_values(map) do
    map
    |> Enum.map(fn {key, value} ->
      {key, Enum.sort(value)}
    end)
    |> Map.new()
  end

  defp count_area_by_lines(map) do
    map
    |> Enum.map(fn {_, line} ->
      count_area_by_line(line)
    end)
    |> Enum.sum()
  end

  defp count_area_by_line(line) do
    line
    |> Enum.chunk_every(2, 2)
    |> Enum.map(fn [x, y] ->
      y - x + 1
    end)
    |> Enum.sum()
  end


  # DEBUG
  #
  defp to_file(drawing, file_path) do
    drawing
    |> Enum.map(fn row ->
      row
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> then(fn content ->
      File.write!(file_path, content)
    end)

    drawing
  end

  defp filter_lines({original_v_line_map, h_line_map}) do
    h_line_map
    |> Enum.reduce(original_v_line_map, fn {y, h_line}, v_line_map ->
      v_line_values = Map.get(v_line_map, y)

      {starts, ends} = h_line |> Enum.unzip()
      both = Enum.concat(starts, ends)

      {ups, downs} =
        both
        |> Enum.reduce({[], []}, fn x, {ups, downs} ->
          above_map = Map.get(original_v_line_map, y - 1, [])

          if x in above_map do
            {[x | ups], downs}
          else
            {ups, [x | downs]}
          end
        end)

      not_on_lines = v_line_values |> Enum.reject(fn x -> x in both end)

      ups_and_not_on_lines = Enum.concat(ups, not_on_lines)
      downs_and_not_on_lines = Enum.concat(downs, not_on_lines)

      new_v_line_values =
        v_line_values
        |> Enum.filter(fn value ->
          cond do
            value in starts ->
              if value in ups do
                rem(length(downs_and_not_on_lines |> Enum.filter(fn x -> x < value end)), 2) == 0
              else
                rem(length(ups_and_not_on_lines |> Enum.filter(fn x -> x < value end)), 2) == 0
              end

            value in ends ->
              if value in ups do
                rem(length(downs_and_not_on_lines |> Enum.filter(fn x -> x > value end)), 2) == 0
              else
                rem(length(ups_and_not_on_lines |> Enum.filter(fn x -> x > value end)), 2) == 0
              end

            true ->
              true
          end
        end)

      Map.put(v_line_map, y, new_v_line_values)
    end)
  end

  # defp get_interior(map) do
  #   # append the previous to last row to the end
  #   (map ++ [Enum.at(map, -2)])
  #   |> Enum.chunk_every(2, 1, :discard)
  #   |> Enum.map(fn [row, row_below] ->
  #     get_interior_row(row, row_below)
  #   end)
  # end
  #
  # defp get_interior_row(row, row_below) do
  #   row
  #   |> Enum.zip(row_below)
  #   |> Enum.reduce({0, []}, fn {char, char_below}, {edge_count, interior} ->
  #     {edge_count, is_inside} =
  #       case {char, char_below} do
  #         {"#", "."} -> {edge_count, true}
  #         {"#", "#"} -> {edge_count + 1, true}
  #         {".", _} -> {edge_count, rem(edge_count, 2) == 1}
  #       end
  #
  #     new_char =
  #       if is_inside do
  #         "#"
  #       else
  #         "."
  #       end
  #
  #     {edge_count, [new_char | interior]}
  #   end)
  #   |> elem(1)
  #   |> Enum.reverse()
  # end
end
