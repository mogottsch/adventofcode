defmodule Day23.Day23 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def part_a(grid) do
    grid
    |> find_path({1, 0}, {length(grid |> Enum.at(0)) - 2, length(grid) - 1})
  end

  defp find_path(grid, pos, goal, visited \\ MapSet.new())

  defp find_path(_grid, pos, goal, visited) when pos == goal do
    visited |> MapSet.size()
  end

  defp find_path(grid, pos, goal, visited) do
    next_positions =
      get_dirs_for_pos(grid, pos)
      |> Enum.map(&direction_to_coords/1)
      |> Enum.map(&move(pos, &1))
      |> Enum.filter(&is_valid_move?(grid, &1, visited))

    if Enum.empty?(next_positions) do
      0
    else
      next_positions
      |> Enum.map(&find_path(grid, &1, goal, visited |> MapSet.put(pos)))
      |> Enum.max()
    end
  end

  defp get_dirs_for_pos(grid, {x, y}) do
    tile = grid |> Enum.at(y) |> Enum.at(x)

    case tile do
      ">" -> [:right]
      "<" -> [:left]
      "^" -> [:up]
      "v" -> [:down]
      _ -> [:up, :down, :left, :right]
    end
  end

  defp direction_to_coords(direction) do
    case direction do
      :up -> {0, -1}
      :down -> {0, 1}
      :left -> {-1, 0}
      :right -> {1, 0}
    end
  end

  defp move({x, y}, {dx, dy}), do: {x + dx, y + dy}

  defp is_valid_move?(grid, {x, y}, visited) do
    in_bounds?(grid, {x, y}) &&
      !is_wall?(grid, {x, y}) &&
      !is_visited?(visited, {x, y})
  end

  defp in_bounds?(grid, {x, y}) do
    x >= 0 && x < grid |> Enum.at(0) |> Enum.count() && y >= 0 && y < grid |> Enum.count()
  end

  defp is_visited?(visited, pos), do: Enum.member?(visited, pos)

  defp get_cell(grid, {x, y}), do: grid |> Enum.at(y) |> Enum.at(x)
  defp is_floor?(grid, pos), do: grid |> get_cell(pos) == "."
  defp is_wall?(grid, pos), do: grid |> get_cell(pos) == "#"
  defp is_slope?(grid, pos), do: get_cell(grid, pos) in ["<", ">", "^", "v"]

  def part_b(grid) do
    grid
    |> remove_slopes()
    |> create_graph()
    |> find_path_on_graph({1, 0}, {length(grid |> Enum.at(0)) - 2, length(grid) - 1})
  end

  defp remove_slopes(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} ->
        if is_slope?(grid, {x, y}) do
          "."
        else
          cell
        end
      end)
    end)
  end

  defp is_node?(grid, {x, y}) do
    if not is_floor?(grid, {x, y}) do
      false
    else
      [:up, :down, :left, :right]
      |> Enum.map(&direction_to_coords/1)
      |> Enum.filter(&in_bounds?(grid, move({x, y}, &1)))
      |> Enum.count(fn {dx, dy} ->
        nx = x + dx
        ny = y + dy
        is_floor?(grid, {nx, ny})
      end) > 2
    end
  end

  def create_graph(grid) do
    grid
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {_, x}, acc ->
        if is_node?(grid, {x, y}) do
          acc |> Map.update({x, y}, [], fn adj -> adj end)
        else
          acc
        end
      end)
    end)
    |> Map.put({1, 0}, [])
    |> Map.put({length(grid |> Enum.at(0)) - 2, length(grid) - 1}, [])
    |> link_nodes(grid)
  end

  defp link_nodes(graph, grid) do
    graph
    |> Map.keys()
    |> Enum.reduce(graph, fn pos, graph ->
      neighbours = walk_till_node(grid, graph |> Map.keys() |> Enum.reject(&(&1 == pos)), pos)

      neighbours =
        if is_list(neighbours) do
          neighbours
        else
          [neighbours]
        end

      graph
      |> Map.put(pos, neighbours)
    end)
  end

  defp walk_till_node(grid, nodes, pos, visited \\ MapSet.new()) do
    if nodes |> Enum.member?(pos) do
      {pos, visited |> MapSet.size()}
    else
      next_positions =
        [:up, :down, :left, :right]
        |> Enum.map(&direction_to_coords/1)
        |> Enum.map(&move(pos, &1))
        |> Enum.filter(&is_valid_move?(grid, &1, visited))

      n_next_positions = Enum.count(next_positions)

      case n_next_positions do
        0 ->
          throw("No next positions")

        1 ->
          walk_till_node(grid, nodes, next_positions |> List.first(), visited |> MapSet.put(pos))

        _ ->
          next_positions
          |> Enum.map(fn next_pos ->
            walk_till_node(grid, nodes, next_pos, visited |> MapSet.put(pos))
          end)
      end
    end
  end

  defp find_path_on_graph(graph, start, goal, visited \\ MapSet.new(), length \\ 0)

  defp find_path_on_graph(_graph, start, goal, _visited, length) when start == goal do
    length
  end

  defp find_path_on_graph(graph, pos, goal, visited, length) do
    neighbours =
      graph
      |> Map.get(pos)
      |> Enum.reject(fn {neighbour, _} -> visited |> MapSet.member?(neighbour) end)

    if Enum.empty?(neighbours) do
      0
    else
      neighbours
      |> Enum.map(fn {neighbour, distance} ->
        find_path_on_graph(graph, neighbour, goal, visited |> MapSet.put(pos), length + distance)
      end)
      |> Enum.max()
    end
  end

  # defp find_path(grid, pos, goal, visited \\ MapSet.new())
  #
  # defp find_path(_grid, pos, goal, visited) when pos == goal do
  #   visited |> MapSet.size()
  # end
  #
  # defp find_path(grid, pos, goal, visited) do
  #   next_positions =
  #     get_dirs_for_pos(grid, pos)
  #     |> Enum.map(&direction_to_coords/1)
  #     |> Enum.map(&move(pos, &1))
  #     |> Enum.filter(&is_valid_move?(grid, &1, visited))
  #
  #   if Enum.empty?(next_positions) do
  #     0
  #   else
  #     next_positions
  #     |> Enum.map(&find_path(grid, &1, goal, visited |> MapSet.put(pos)))
  #     |> Enum.max()
  #   end
  # end
end
