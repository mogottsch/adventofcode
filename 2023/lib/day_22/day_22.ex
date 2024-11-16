defmodule Day22.Day22 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_brick/1)
  end

  defp parse_brick(line) do
    line |> String.split("~") |> Enum.map(&parse_coords/1) |> List.to_tuple()
  end

  defp parse_coords(line) do
    line |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  def part_a(input) do
    vecs =
      input
      |> Enum.map(&convert_to_vector/1)

    # intersect?(a, b) |> IO.inspect(label: "intersect?")

    # IO.puts("-----")
    #
    # vecs
    # |> visualize(:y)
    #
    # IO.puts("-----")
    #
    # vecs
    # |> visualize(:x)

    vecs = fall_until_stable(vecs)

    IO.puts("---new--")

    vecs
    |> visualize(:y)

    IO.puts("-----")

    vecs
    |> visualize(:x)

    # i = 6
    # vec = vecs |> Enum.at(i)
    # find_carriers(vec, vecs |> List.delete_at(i)) |> IO.inspect(label: "carriers")
    # throw(:stop)
    carrier_map = vecs |> get_carrier_map()
    carrier_map |> IO.inspect(label: "carrier_map", limit: :infinity)

    reverse_carrier_map =
      carrier_map
      |> reverse_map()

    reverse_carrier_map |> IO.inspect(label: "reverse_carrier_map", limit: :infinity)

    vecs
    |> Enum.with_index()
    |> Enum.filter(fn {vec, i} -> can_be_disintegrated?(i, carrier_map, reverse_carrier_map) end)
    # |> IO.inspect(label: "disintegrateable")
    |> Enum.map(fn {vec, i} -> i end)
    |> IO.inspect(label: "disintegrated", limit: :infinity)
    |> Enum.count()
  end

  defp can_be_disintegrated?(index, carrier_map, reverse_carrier_map) do
    carries = reverse_carrier_map |> Map.get(index, [])

    if Enum.count(carries) == 0 do
      true
    else
      Enum.all?(carries, fn i -> Enum.count(carrier_map[i]) > 1 end)
    end
  end

  defp reverse_map(map) do
    map
    |> Map.keys()
    |> Enum.reduce(%{}, fn key, acc ->
      map[key] |> Enum.reduce(acc, fn i, acc -> acc |> Map.update(i, [key], &(&1 ++ [key])) end)
    end)
  end

  defp get_carrier_map(vecs) do
    vecs
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {vec, i}, acc ->
      acc |> Map.put(i, find_carriers(vec, vecs |> List.delete_at(i)))
    end)
  end

  defp translate_map_to_char_map(carrier_map) do
    carrier_map
    |> Map.keys()
    |> Enum.reduce(%{}, fn i, acc ->
      acc
      |> Map.put(
        List.to_string([?A + i]),
        List.to_string(carrier_map[i] |> Enum.map(fn i -> ?A + i end))
      )
    end)
  end

  defp fall_until_stable(vecs) do
    case fall(vecs) do
      {:stable, vecs} ->
        vecs

      {:fallen, vecs} ->
        fall_until_stable(vecs)
    end
  end

  defp fall(vecs) do
    vecs
    |> Enum.with_index()
    |> Enum.reduce({true, []}, fn {vec, i}, {is_stable, new_vecs} ->
      case fall_vec(vec, vecs |> List.delete_at(i)) do
        {:stable, vec} ->
          {is_stable, [vec | new_vecs]}

        {:fallen, vec} ->
          {false, [vec | new_vecs]}
      end
    end)
    |> then(fn
      {true, vecs} ->
        {:stable, vecs |> Enum.reverse()}

      {false, vecs} ->
        {:fallen, vecs |> Enum.reverse()}
    end)
  end

  defp fall_vec({start_coords, direction_vector, length}, vecs) do
    new_vec = move_down({start_coords, direction_vector, length})
    {[_, _, z], _, _} = new_vec

    if z < 1 or Enum.any?(vecs, &intersect?(new_vec, &1)) do
      {:stable, {start_coords, direction_vector, length}}
    else
      {:fallen, new_vec}
    end
  end

  defp move_down(vec) do
    {start_coords, direction_vector, length} = vec
    [x, y, z] = start_coords
    new_start_coords = [x, y, z - 1]

    {new_start_coords, direction_vector, length}
  end

  defp find_carriers(vec, vecs) do
    new_vec = move_down(vec)

    vecs
    |> Enum.with_index()
    |> Enum.filter(fn {other_vec, _} -> intersect?(new_vec, other_vec) end)
    |> Enum.map(fn {_, i} -> i end)
  end

  defp visualize(vecs, axis) do
    axis = axis_to_index(axis)
    # drop axis
    vecs =
      vecs
      |> Enum.map(fn {start, dir, length} ->
        {start |> List.delete_at(axis), dir |> List.delete_at(axis), length}
      end)

    [x_max, y_max] =
      vecs
      |> Enum.map(fn {start, dir, length} ->
        start |> Enum.zip(dir) |> Enum.map(fn {x, y} -> x + y * length end)
      end)
      |> Enum.reduce([0, 0], fn [x, y], [x_max, y_max] ->
        [max(x, x_max), max(y, y_max)]
      end)

    # iterate over all points
    0..y_max
    |> Enum.map(fn y ->
      0..x_max
      |> Enum.map(fn x ->
        vecs
        |> Enum.with_index()
        |> Enum.reduce([], fn {vec, i}, acc ->
          if is_point_on_line?([x, y], vec) do
            [i | acc]
          else
            acc
          end
        end)
        |> then(fn
          [] -> "."
          [i] -> ?A + i
          _ -> "?"
        end)
      end)
    end)
    |> Enum.reverse()
    |> Enum.join("\n")
    |> IO.puts()
  end

  defp axis_to_index(axis) do
    case axis do
      :x -> 0
      :y -> 1
      :z -> 2
    end
  end

  defp convert_to_vector({start_coords, end_coords}) do
    dir =
      start_coords
      |> Enum.zip(end_coords)
      |> Enum.map(fn {start, e} -> e - start end)

    # this only works because the direction only moves in one dimension
    normalized_dir =
      dir
      |> Enum.map(&normalize/1)

    length = dir |> Enum.map(&abs/1) |> Enum.sum()

    {start_coords, normalized_dir, length}
  end

  defp normalize(0), do: 0
  defp normalize(x) when x > 0, do: 1
  defp normalize(x) when x < 0, do: -1

  defp is_point_on_line?(point, {start_point, direction_vector, length}) do
    if direction_vector == [0, 0] do
      point == start_point
    else
      # Compute the vector from start_point to point
      vector_to_point = Enum.zip_with(point, start_point, fn p, s -> p - s end)

      # Check if the vector to the point is parallel to the direction vector
      is_parallel = cross_product(vector_to_point, direction_vector) == 0

      # If parallel, check if the point is within the length of the segment
      if is_parallel do
        distance_to_point = vector_to_point |> Enum.max_by(&abs/1)
        distance_to_point <= length and distance_to_point >= 0
      else
        false
      end
    end
  end

  defp intersect?({a_start, a_dir, a_length}, {b_start, b_dir, b_length}) do
    # [a_x_min, a_y_min, a_z_min] = a_start
    # [a_x_max, a_y_max, a_z_max] = Enum.zip_with(a_start, a_dir, fn x, y -> x + y * a_length end)
    #
    # [b_x_min, b_y_min, b_z_min] = b_start
    # [b_x_max, b_y_max, b_z_max] = Enum.zip_with(b_start, b_dir, fn x, y -> x + y * b_length end)
    # # return (
    # #     other.min_x <= self.max_x
    # #     and other.max_x >= self.min_x
    # #     and other.min_y <= self.max_y
    # #     and other.max_y >= self.min_y
    # #     and other.min_z <= self.max_z
    # #     and other.max_z >= self.min_z
    # # )
    # if b_x_min <= a_x_max and b_x_max >= a_x_min and
    #      b_y_min <= a_y_max and b_y_max >= a_y_min and
    #      b_z_min <= a_z_max and b_z_max >= a_z_min do
    #   true
    # else
    #   false
    # end

    case solve_system({a_start, a_dir}, {b_start, b_dir}) do
      :no_solution ->
        false

      {:ok, t1, t2} ->
        p1 = Enum.zip_with(a_start, a_dir, fn x, y -> x + y * t1 end)
        p2 = Enum.zip_with(b_start, b_dir, fn x, y -> x + y * t2 end)

        p1 == p2 and t1 >= 0 and t1 <= a_length and t2 >= 0 and t2 <= b_length
    end
  end

  defp cross_product([x1, y1, z1], [x2, y2, z2]) do
    [y1 * z2 - z1 * y2, z1 * x2 - x1 * z2, x1 * y2 - y1 * x2]
  end

  defp cross_product([x1, y1], [x2, y2]) do
    x1 * y2 - y1 * x2
  end

  defp dot_product([x1, y1, z1], [x2, y2, z2]) do
    x1 * x2 + y1 * y2 + z1 * z2
  end

  defp solve_system({s1, d1}, {s2, d2}) do
    r = Enum.zip_with(s2, s1, fn x, y -> x - y end)

    d1xd2 = cross_product(d1, d2)

    if Enum.all?(d1xd2, &(&1 == 0)) do
      :no_solution
    else
      t1 = dot_product(r, cross_product(d2, d1xd2)) / dot_product(d1xd2, d1xd2)
      t2 = dot_product(r, cross_product(d1, d1xd2)) / dot_product(d1xd2, d1xd2)

      {:ok, t1, t2}
    end
  end

  def part_b(input) do
    # Your code here
  end

  # defp count_coords_different({start_coords, end_coords}) do
  #   start_coords
  #   |> Tuple.to_list()
  #   |> Enum.zip(end_coords |> Tuple.to_list())
  #   |> Enum.map(fn {start, e} -> e - start end)
  #   |> Enum.count(fn x -> x != 0 end)
  # end
end
