defmodule Day08.Day08 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n\n")
    |> List.to_tuple()
    |> then(fn {directions, network} ->
      {directions |> String.split("", trim: true), parse_network(network)}
    end)
  end

  defp parse_network(network) do
    network
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" = ")
      |> then(fn [from, to] ->
        {from,
         to |> String.trim("(") |> String.trim(")") |> String.split(", ") |> List.to_tuple()}
      end)
    end)
    |> Map.new()
  end

  def part_a({directions, network}) do
    directions
    |> recurse(network, "AAA", 0)
  end

  defp recurse(directions, network, node, i) do
    direction = directions |> Enum.at(rem(i, length(directions)))
    next_node = get_next_node(node, direction, network)

    case next_node do
      "ZZZ" -> i + 1
      _ -> recurse(directions, network, next_node, i + 1)
    end
  end

  defp get_next_node(node, direction, network) do
    case direction do
      "L" -> network[node] |> elem(0)
      "R" -> network[node] |> elem(1)
      _ -> throw("Unknown direction: #{direction}")
    end
  end

  def part_b({directions, network}) do
    starting_nodes = network |> Map.keys() |> get_nodes_ending_with("A")

    starting_nodes
    |> Enum.map(fn node ->
      get_nth_distance_to_z(network, directions, 0, node, 2, 0) -
        get_nth_distance_to_z(network, directions, 0, node, 1, 0)
    end)
    |> lcm_list()
  end

  defp get_nodes_ending_with(network, char) do
    network
    |> Enum.filter(fn from ->
      from |> String.ends_with?(char)
    end)
  end

  defp get_nth_distance_to_z(network, directions, i, node, n_end, n_current) do
    next_node = get_next_node(node, directions |> Enum.at(rem(i, length(directions))), network)

    new_n = get_new_n(next_node, n_current)

    if new_n == n_end do
      i + 1
    else
      get_nth_distance_to_z(network, directions, i + 1, next_node, n_end, new_n)
    end
  end

  defp get_new_n(node, n_current) do
    if node |> String.ends_with?("Z") do
      n_current + 1
    else
      n_current
    end
  end

  defp lcm(a, b) do
    (a * b / gcd(a, b)) |> round()
  end

  defp gcd(a, 0), do: a
  defp gcd(a, b), do: gcd(b, rem(a, b))

  def lcm_list([head | tail]) do
    Enum.reduce(tail, head, &lcm/2)
  end
end
