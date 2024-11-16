defmodule Day24.Day24 do
  import Nx.Defn

  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_hailstone/1)
  end

  defp parse_hailstone(line) do
    line |> String.split(" @ ") |> Enum.map(&parse_vector/1) |> List.to_tuple()
  end

  defp parse_vector(line) do
    line
    |> String.split(", ")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  def part_a(input) do
    is_example = length(input) == 5
    {min, max} = if is_example, do: {7, 27}, else: {200_000_000_000_000, 400_000_000_000_000}

    input
    |> Enum.map(&remove_z/1)
    |> pairs()
    |> Enum.map(fn {x, y} -> get_future_intersection(x, y) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn [x, y] ->
      x >= min and x <= max and y >= min and y <= max
    end)
    |> Enum.count()
  end

  defp remove_z({loc_vec, vel_vec}) do
    {Enum.take(loc_vec, 2), Enum.take(vel_vec, 2)}
  end

  defp pairs(list) do
    for x <- list, y <- list, x < y, do: {x, y}
  end

  defp get_future_intersection({a_start, a_dir}, {b_start, b_dir}) do
    case solve_system({a_start, a_dir}, {b_start, b_dir}) do
      :no_solution ->
        nil

      {:ok, t1, t2} ->
        p = Enum.zip_with(a_start, a_dir, fn x, y -> x + y * t1 end)

        if t1 >= 0 and t2 >= 0 do
          p
        else
          nil
        end
    end
  end

  defp cross_product([x1, y1], [x2, y2]) do
    x1 * y2 - y1 * x2
  end

  defp solve_system({s1, d1}, {s2, d2}) do
    r = Enum.zip_with(s2, s1, fn x, y -> x - y end)

    d1xd2 = cross_product(d1, d2)

    if d1xd2 == 0 do
      :no_solution
    else
      t1 = cross_product(r, d2) / d1xd2
      t2 = cross_product(r, d1) / d1xd2

      {:ok, t1, t2}
    end
  end

  def part_b(input) do
    input |> IO.inspect()

    matrix_a =
      create_matrix_a(input |> Enum.slice(0..2))
      |> IO.inspect()

    solve_linear_equations(matrix_a, [0, 0, 0, 0, 0, 0])
    |> IO.inspect()
  end

  defp create_matrix_a([
         {[p0x, p0y, p0z], [v0x, v0y, v0z]},
         {[p1x, p1y, p1z], [v1x, v1y, v1z]},
         {[p2x, p2y, p2z], [v2x, v2y, v2z]}
       ]) do
    [
      [-(p1z - p0z), p1y - p0y, 0, -(v1z - v0z), 0, -(v1y - v0y)],
      [p1z - p0z, 0, -(p1x - p0x), 0, -(v1z - v0z), v1x - v0x],
      [0, -(p1y - p0y), p1x - p0x, v1y - v0y, v1x - v0x, 0],
      [-(p2z - p0z), p2y - p0y, 0, -(v2z - v0z), 0, -(v2y - v0y)],
      [p2z - p0z, 0, -(p2x - p0x), 0, -(v2z - v0z), v2x - v0x],
      [0, -(p2y - p0y), p2x - p0x, v2y - v0y, v2x - v0x, 0]
    ]
  end

  def solve_linear_equations(matrix_a, vector_b) do
    a = Nx.tensor(matrix_a)
    b = Nx.tensor(vector_b)

    # Solving for x in Ax = b
    x = Nx.LinAlg.solve(a, b)

    Nx.to_flat_list(x)
  end
end
