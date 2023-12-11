defmodule Day11.Day11 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def part_a(space) do
    space
    |> find_galaxies()
    |> expand_galaxies_across_space_by(space, 1)
    |> pairs()
    |> Enum.map(&distance/1)
    |> Enum.sum()
  end

  defp expand(space) do
    empty_rows =
      space
      |> index_of_empty_rows()

    empty_cols =
      space
      |> transpose()
      |> index_of_empty_rows()

    space |> expand_rows(empty_rows) |> transpose() |> expand_rows(empty_cols) |> transpose()
  end

  defp index_of_empty_rows(space) do
    space
    |> Enum.with_index()
    |> Enum.filter(fn {row, _} -> Enum.all?(row, &(&1 == ".")) end)
    |> Enum.map(fn {_, row_index} -> row_index end)
  end

  defp transpose(space), do: space |> Enum.zip_with(&Function.identity/1)

  defp expand_rows(space, row_indexes) do
    space
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_index} ->
      if Enum.member?(row_indexes, row_index) do
        [row, row]
      else
        [row]
      end
    end)
  end

  defp expand_galaxies_across_space_by(galaxies, space, n) do
    empty_rows =
      space
      |> index_of_empty_rows()

    empty_cols =
      space
      |> transpose()
      |> index_of_empty_rows()

    galaxies
    |> expand_galaxies_across_dimension(empty_cols, n, :col)
    |> expand_galaxies_across_dimension(empty_rows, n, :row)
  end

  defp expand_galaxies_across_dimension(galaxies, indices, n, dimension) do
    galaxies
    |> Enum.map(fn {row, col} ->
      el_index =
        if dimension == :row do
          row
        else
          col
        end

      empty_before =
        indices
        |> Enum.filter(fn index -> index < el_index end)
        |> Enum.count()

      if dimension == :row do
        {row + empty_before * n, col}
      else
        {row, col + empty_before * n}
      end
    end)
  end

  # get positions of '#' in two dimensional array
  defp find_galaxies(space) do
    space
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {col, col_index} ->
        case col do
          "#" -> {row_index, col_index}
          _ -> nil
        end
      end)
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  defp pairs(galaxies) do
    for x <- galaxies, y <- galaxies, x < y, do: {x, y}
  end

  defp distance({{x1, y1}, {x2, y2}}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def part_b(space) do
    space
    |> find_galaxies()
    |> expand_galaxies_across_space_by(space, 999_999)
    |> pairs()
    |> Enum.map(&distance/1)
    |> Enum.sum()
  end
end
