defmodule Day13.Day13 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_grid/1)
  end

  defp parse_grid(grid) do
    grid
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split("", trim: true)
  end

  def part_a(grids) do
    grids
    |> Enum.map(&find_mirror_axis/1)
    |> Enum.map(&derive_score/1)
    |> Enum.sum()
  end

  defp find_mirror_axis(grid) do
    case find_mirror_axis_in_rows(grid) do
      {_, index} ->
        {index, :row}

      nil ->
        {grid |> transpose() |> find_mirror_axis_in_rows() |> elem(1), :column}
    end
  end

  defp find_mirror_axis_in_rows(grid) do
    grid
    |> Enum.map(&Enum.join/1)
    |> Enum.with_index()
    |> Enum.find(fn {_row, index} ->
      index |> check_mirror_axis_in_row(grid)
    end)
  end

  defp transpose(grid) do
    grid |> Enum.zip_with(&Function.identity/1)
  end

  defp check_mirror_axis_in_row(index, grid) do
    current_row = grid |> Enum.at(index)
    next_row = grid |> Enum.at(index + 1)

    if next_row != current_row do
      false
    else
      {left_grid, right_grid} = grid |> Enum.split(index)
      new_grid = left_grid ++ (right_grid |> Enum.drop(2))

      if length(left_grid) == 0 or length(right_grid) == 2 do
        true
      else
        check_mirror_axis_in_row(index - 1, new_grid)
      end
    end
  end

  defp derive_score({index, :row}), do: (index + 1) * 100
  defp derive_score({index, :column}), do: index + 1

  def part_b(grid) do
    grid
    |> Enum.map(&find_mirror_axis_smudged/1)
    |> Enum.map(&derive_score/1)
    |> Enum.sum()
  end

  defp find_mirror_axis_smudged(grid) do

    case find_mirror_axis_in_rows_smudged(grid) do
      {_, index} ->
        {index, :row}

      nil ->
        {grid |> transpose() |> find_mirror_axis_in_rows_smudged() |> elem(1), :column}
    end
  end

  defp find_mirror_axis_in_rows_smudged(grid) do
    grid
    |> Enum.map(&Enum.join/1)
    |> Enum.with_index()
    |> Enum.find(fn {_row, index} ->
      index |> check_mirror_axis_in_row_smudged(grid)
    end)
  end

  defp check_mirror_axis_in_row_smudged(index, grid, remaining_smudges \\ 1) do
    current_row = grid |> Enum.at(index)
    next_row = grid |> Enum.at(index + 1)

    n_differences =
      if next_row == nil do
        length(current_row)
      else
        count_differences(current_row, next_row)
      end

    case {n_differences, remaining_smudges} do
      {1, 1} -> check_mirror_axis_in_row_splitted(index, grid, remaining_smudges - 1)
      {0, _} -> check_mirror_axis_in_row_splitted(index, grid, remaining_smudges)
      {_, _} -> false
    end
  end

  defp check_mirror_axis_in_row_splitted(index, grid, remaining_smudges) do
    {left_grid, right_grid} = grid |> Enum.split(index)
    new_grid = left_grid ++ (right_grid |> Enum.drop(2))

    if length(left_grid) == 0 or length(right_grid) == 2 do
      remaining_smudges == 0
    else
      check_mirror_axis_in_row_smudged(index - 1, new_grid, remaining_smudges)
    end
  end

  def count_differences(list1, list2) do
    list1
    |> Enum.zip(list2)
    |> Enum.count(fn {a, b} -> a != b end)
  end
end
