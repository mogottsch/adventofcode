defmodule Day17.Day17 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defmacro direction(direction_atom) do
    case direction_atom do
      quote(do: :up) -> quote(do: {0, -1})
      quote(do: :right) -> quote(do: {1, 0})
      quote(do: :down) -> quote(do: {0, 1})
      quote(do: :left) -> quote(do: {-1, 0})
    end
  end

  def part_a(grid) do
    start_point = {0, 0}
    end_point = {Enum.count(grid) - 1, Enum.count(Enum.at(grid, 0)) - 1}

    retrieve_next_dirs = fn last_dir ->
      [direction(:up), direction(:right), direction(:down), direction(:left)]
      |> Enum.filter(fn dir -> dir != last_dir |> normalize_dir() |> reverse_dir() end)
      |> Enum.filter(fn dir -> last_dir |> update_dir(dir) |> too_long?() == false end)
    end

    run_dijkstra(grid, start_point, end_point, retrieve_next_dirs)
  end

  defp run_dijkstra(grid, start, finish, retrieve_next_dirs_func) do
    visited = MapSet.new()

    queue =
      Heap.new()
      |> enqueue({0, {start, {0, 0}}})

    min_dists = Map.new()

    # prev_pos = Map.new()
    # prev_pos = Map.put(prev_pos, start, nil)

    min_dists = Map.put(min_dists, start, 0)

    # {min_dists, _prev_pos} =
    min_dists =
      run_dijkstra_until_finish(
        grid,
        queue,
        visited,
        min_dists,
        # prev_pos,
        finish,
        retrieve_next_dirs_func
      )

    min_dists |> Map.get(finish)
  end

  defp run_dijkstra_until_finish(
         grid,
         queue,
         visited,
         min_dists,
         # prev_pos,
         finish,
         retrieve_next_dirs
       ) do
    if Heap.empty?(queue) do
      # {min_dists, prev_pos}
      min_dists
    else
      {heat, _} = Heap.root(queue)
      finish_heat = Map.get(min_dists, finish, heat)

      if finish_heat != nil && heat > finish_heat do
        # {min_dists, prev_pos}
        min_dists
      else
        {
          queue,
          visited,
          min_dists
          # prev_pos
        } =
          run_dijkstra_step(
            grid,
            queue,
            visited,
            min_dists,
            # prev_pos,
            retrieve_next_dirs
          )

        run_dijkstra_until_finish(
          grid,
          queue,
          visited,
          min_dists,
          # prev_pos,
          finish,
          retrieve_next_dirs
        )
      end
    end
  end

  defp run_dijkstra_step(
         grid,
         queue,
         visited,
         min_dists,
         # prev_pos,
         retrieve_next_dirs
       ) do
    {{heat, {pos, last_dir}}, queue} = dequeue(queue)

    retrieve_next_dirs.(last_dir)
    |> Enum.map(fn dir -> {move(pos, dir), update_dir(last_dir, dir)} end)
    |> Enum.filter(fn {new_pos, new_dir} -> valid_move(grid, visited, new_pos, new_dir) end)
    |> Enum.reduce(
      {
        queue,
        visited,
        min_dists
        # prev_pos
      },
      # prev_pos
      fn {{x, y}, new_dir},
         {
           queue,
           visited,
           min_dists
         } ->
        process_step(
          grid,
          queue,
          visited,
          min_dists,
          # prev_pos,
          heat,
          {{x, y}, new_dir}
        )
      end
    )
  end

  defp process_step(
         grid,
         queue,
         visited,
         min_dists,
         # prev_pos,
         heat,
         {{x, y}, new_dir}
       ) do
    additional_heat = grid |> Enum.at(y) |> Enum.at(x)
    new_heat = heat + additional_heat
    old_heat = Map.get(min_dists, {x, y})

    is_better = old_heat == nil || new_heat < old_heat

    min_dists =
      if is_better do
        Map.put(min_dists, {x, y}, new_heat)
      else
        min_dists
      end

    # prev_pos =
    #   if is_better do
    #     Map.put(prev_pos, {x, y}, pos)
    #   else
    #     prev_pos
    #   end

    pos_dir_tuple = {{x, y}, new_dir}

    {
      queue |> enqueue({new_heat, pos_dir_tuple}),
      visited |> MapSet.put(pos_dir_tuple),
      min_dists
      # prev_pos
    }
  end

  defp valid_move(grid, visited, pos, dir) do
    is_in_bounds = in_bounds?(grid, pos)
    is_not_visited = !MapSet.member?(visited, {pos, dir})

    is_in_bounds && is_not_visited
  end

  defp in_bounds?(grid, {x, y}) do
    x >= 0 && x < Enum.count(grid) && y >= 0 && y < Enum.count(Enum.at(grid, 0))
  end

  defp move({x, y}, {dx, dy}), do: {x + dx, y + dy}
  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :right), do: {x + 1, y}
  defp move({x, y}, :down), do: {x, y + 1}
  defp move({x, y}, :left), do: {x - 1, y}

  defp update_dir({dx1, dy1}, {dx2, dy2}) do
    {ndx1, ndy1} = normalize_dir({dx1, dy1})

    cond do
      ndx1 == dx2 && ndy1 == dy2 -> {dx1 + dx2, dy1 + dy2}
      true -> {dx2, dy2}
    end
  end

  # either contains 0 or 1 
  defp normalize_dir({dx, dy}) do
    cond do
      dx == 0 && dy == 0 -> {0, 0}
      dx == 0 && dy < 0 -> {0, -1}
      dx == 0 && dy > 0 -> {0, 1}
      dx < 0 && dy == 0 -> {-1, 0}
      dx > 0 && dy == 0 -> {1, 0}
    end
  end

  defp reverse_dir({dx, dy}) do
    {-dx, -dy}
  end

  defp too_long?({dx, dy}, max_length \\ 3) do
    abs(dx) > max_length || abs(dy) > max_length
  end

  defp enqueue(queue, node) do
    Heap.push(queue, node)
  end

  defp dequeue(queue) do
    {root, rest} = Heap.split(queue)
    {root, rest}
  end

  def part_b(grid) do
    start_point = {0, 0}
    end_point = {Enum.count(grid) - 1, Enum.count(Enum.at(grid, 0)) - 1}

    retrieve_next_dirs = fn last_dir ->
      cond do
        last_dir == {0, 0} ->
          [direction(:right), direction(:down)]

        absolute_trajectory_length(last_dir) < 4 ->
          [normalize_dir(last_dir)]

        true ->
          [direction(:up), direction(:right), direction(:down), direction(:left)]
          |> Enum.filter(fn dir -> dir != last_dir |> normalize_dir() |> reverse_dir() end)
          |> Enum.filter(fn dir -> last_dir |> update_dir(dir) |> too_long?(10) == false end)
      end
    end

    run_dijkstra(grid, start_point, end_point, retrieve_next_dirs)
  end

  defp absolute_trajectory_length({dx, dy}) do
    abs(dx) + abs(dy)
  end

  # --- DEBUG
  # defp visualize_queue(grid, queue) do
  #   queue =
  #     queue
  #     |> queue_to_list()
  #
  #   grid
  #   |> Enum.with_index()
  #   |> Enum.map(fn {row, y} ->
  #     row
  #     |> Enum.with_index()
  #     |> Enum.map(fn {_, x} ->
  #       if Enum.any?(queue, fn {_, {{ox, oy}, _}} -> ox == x && oy == y end) do
  #         "X"
  #       else
  #         " "
  #       end
  #     end)
  #   end)
  # end
  #
  # defp visualize_path(grid, prev_pos, finish) do
  #   path = retrieve_path(prev_pos, finish)
  #
  #   grid
  #   |> Enum.with_index()
  #   |> Enum.map(fn {row, y} ->
  #     row
  #     |> Enum.with_index()
  #     |> Enum.map(fn {_, x} ->
  #       hits = Enum.filter(path, fn {ox, oy} -> ox == x && oy == y end) |> Enum.count()
  #
  #       if hits > 0 do
  #         hits |> to_string()
  #       else
  #         " "
  #       end
  #     end)
  #   end)
  # end
  #
  # defp visualize_min_dists(grid, min_dists) do
  #   grid
  #   |> Enum.with_index()
  #   |> Enum.map(fn {row, y} ->
  #     row
  #     |> Enum.with_index()
  #     |> Enum.map(fn {_, x} ->
  #       Map.get(min_dists, {x, y}, " ") |> to_string()
  #     end)
  #   end)
  # end
  #
  # defp retrieve_path(_, nil) do
  #   []
  # end
  #
  # # defp retrieve_path(_, {1, 0}) do
  # #   []
  # # end
  #
  # defp retrieve_path(prev_pos, current) do
  #   [current | retrieve_path(prev_pos, Map.get(prev_pos, current))]
  # end
  #
  # defp queue_to_list(queue) do
  #   if Heap.empty?(queue) do
  #     []
  #   else
  #     {root, rest} = Heap.split(queue)
  #     [root | queue_to_list(rest)]
  #   end
  # end
end
