defmodule Day03.Day03 do
  @null_string "."
  @adjacent_symbol "X"
  @gear_symbol "*"

  def part_a(input) do
    parsed_file = input
    part_adj_matrix = parsed_file |> get_adjacency_matrix()
    number_matrix = parsed_file |> get_number_matrix()

    number_matrix
    |> NumberIdentifier.identify_number_groups(@null_string)
    |> Enum.filter(&is_valid_number_group?(&1, part_adj_matrix))
    |> Enum.map(&retrieve_number_value(&1, number_matrix))
    |> Enum.sum()
  end

  def parse_file(file_path) do
    {:ok, file} = File.read(file_path)
    String.split(file, "\n", trim: true) |> Enum.map(&String.split(&1, "", trim: true))
  end

  defp get_adjacency_matrix(matrix) do
    Enum.with_index(matrix, fn row, row_idx ->
      Enum.with_index(row, fn _cell, col_idx ->
        if is_adjacent_to_symbol?(matrix, row_idx, col_idx),
          do: @adjacent_symbol,
          else: @null_string
      end)
    end)
  end

  defp get_number_matrix(matrix) do
    Enum.map(matrix, fn row ->
      Enum.map(row, fn cell ->
        if is_number?(cell), do: cell, else: @null_string
      end)
    end)
  end

  defp is_adjacent_to_symbol?(matrix, row_idx, col_idx) do
    delta_rows = [-1, 0, 1]
    delta_cols = [-1, 0, 1]

    Enum.map(delta_rows, fn delta_row ->
      Enum.map(delta_cols, fn delta_col ->
        value = Enum.at(Enum.at(matrix, row_idx + delta_row, []), col_idx + delta_col)

        if value == nil do
          false
        else
          if is_symbol?(value) do
            true
          else
            false
          end
        end
      end)
    end)
    |> Enum.flat_map(& &1)
    |> Enum.any?()
  end

  defp is_valid_number_group?(group, part_adj_matrix) do
    group
    |> Enum.map(fn {row_idx, col_idx} ->
      Enum.at(Enum.at(part_adj_matrix, row_idx), col_idx)
    end)
    |> Enum.any?(&(&1 == @adjacent_symbol))
  end

  defp retrieve_number_value(group, number_matrix) do
    group
    |> Enum.map(fn {row_idx, col_idx} ->
      Enum.at(Enum.at(number_matrix, row_idx), col_idx)
    end)
    |> Enum.join()
    |> String.to_integer()
  end

  defp is_dot?(char) do
    char == @null_string
  end

  defp is_number?(char) do
    char in (0..9 |> Enum.map(&Integer.to_string(&1)))
  end

  defp is_symbol?(char) do
    not is_dot?(char) and not is_number?(char)
  end

  def part_b(input) do
    parsed_file = input

    number_matrix = parsed_file |> get_number_matrix()

    number_groups =
      number_matrix
      |> NumberIdentifier.identify_number_groups(@null_string)

    parsed_file
    |> get_potential_gear_locations()
    |> identify_gear_neighbor_number_groups(number_groups)
    |> Enum.map(fn group_group ->
      group_group
      |> Enum.map(fn group ->
        group |> retrieve_number_value(number_matrix)
      end)
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  defp get_potential_gear_locations(matrix) do
    matrix
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, row_idx}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, col_idx}, acc ->
        if is_gear?(cell) do
          [{row_idx, col_idx} | acc]
        else
          acc
        end
      end)
    end)
  end

  defp identify_gear_neighbor_number_groups(potential_gear_locations, number_groups) do
    delta_rows = [-1, 0, 1]
    delta_cols = [-1, 0, 1]

    potential_gear_locations
    |> Enum.map(fn {row_idx, col_idx} ->
      number_groups
      |> Enum.filter(fn group ->
        Enum.any?(delta_rows, fn delta_row ->
          Enum.any?(delta_cols, fn delta_col ->
            Enum.any?(group, fn {r, c} ->
              r == row_idx + delta_row and c == col_idx + delta_col
            end)
          end)
        end)
      end)
    end)
    |> Enum.filter(&(length(&1) == 2))
  end

  defp is_gear?(char) do
    char == @gear_symbol
  end
end

defmodule NumberIdentifier do
  def identify_number_groups(matrix, null_string) do
    n = length(Enum.at(matrix, 0))
    m = length(matrix)

    initial_assigned_matrix = for _ <- 1..m, do: List.duplicate(false, n)
    initial_groups = []

    Enum.reduce(
      0..(m - 1),
      {initial_groups, initial_assigned_matrix},
      fn row_idx, acc ->
        Enum.reduce(0..(n - 1), acc, fn col_idx, acc_inner ->
          cell = Enum.at(Enum.at(matrix, row_idx), col_idx)

          {groups, assigned_matrix} = acc_inner

          if cell != null_string and not Enum.at(Enum.at(assigned_matrix, row_idx), col_idx) do
            {new_group, new_assigned_matrix} =
              dfs(matrix, assigned_matrix, row_idx, col_idx, [], null_string)

            {[new_group |> Enum.reverse() | groups], new_assigned_matrix}
          else
            {groups, assigned_matrix}
          end
        end)
      end
    )
    |> elem(0)
  end

  defp dfs(matrix, assigned_matrix, row_idx, col_idx, acc, null_string) do
    if row_idx < 0 or row_idx >= length(matrix) or col_idx < 0 or
         col_idx >= length(Enum.at(matrix, row_idx)) or
         Enum.at(Enum.at(matrix, row_idx), col_idx) == null_string or
         Enum.at(Enum.at(assigned_matrix, row_idx), col_idx) do
      {acc, assigned_matrix}
    else
      new_acc = [{row_idx, col_idx} | acc]

      new_assigned_matrix =
        Enum.with_index(assigned_matrix, fn row, r_idx ->
          Enum.with_index(row, fn cell, c_idx ->
            if r_idx == row_idx and c_idx == col_idx do
              true
            else
              cell
            end
          end)
        end)

      [{0, -1}, {0, 1}]
      |> Enum.reduce({new_acc, new_assigned_matrix}, fn {dr, dc}, {acc, assigned_matrix} ->
        dfs(matrix, assigned_matrix, row_idx + dr, col_idx + dc, acc, null_string)
      end)
    end
  end
end
