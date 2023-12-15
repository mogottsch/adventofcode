defmodule Day15.Day15 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.replace("\n", "")
    |> String.split(",")
  end

  defp hash(string) do
    string
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, hash_value ->
      rem((char + hash_value) * 17, 256)
    end)
  end

  def part_a(input) do
    input |> Enum.map(&hash/1) |> Enum.sum()
  end

  def part_b(input) do
    boxes = %{}

    input
    |> parse_instructions()
    |> Enum.reduce(boxes, fn {box, instruction}, boxes ->
      Map.put(boxes, box, execute_instruction(instruction, Map.get(boxes, box, [])))
    end)
    |> Enum.map(fn {box, content} ->
      content
      |> Enum.with_index()
      |> Enum.map(fn {{_, focal_length}, index} ->
        (box + 1) * (length(content) - index) * focal_length
      end)
    end)
    |> List.flatten()
    |> Enum.sum()
  end

  defp parse_instructions(input) do
    input
    |> Enum.map(fn instruction ->
      if String.contains?(instruction, "=") do
        parse_assignment(instruction)
      else
        parse_deletion(instruction)
      end
    end)
  end

  defp parse_assignment(instruction) do
    [label, focal_length] = String.split(instruction, "=")
    {hash(label), {:assignment, label, String.to_integer(focal_length)}}
  end

  defp parse_deletion(instruction) do
    [label, _] = String.split(instruction, "-")
    {hash(label), {:deletion, label}}
  end

  defp execute_instruction({:assignment, label, focal_length}, box_content) do
    {found, box_content} =
      box_content
      |> Enum.reduce({false, []}, fn {other_label, other_focal_length}, {found, content} ->
        if label == other_label do
          {true, content ++ [{label, focal_length}]}
        else
          {found, content ++ [{other_label, other_focal_length}]}
        end
      end)

    if found do
      box_content
    else
      [{label, focal_length} | box_content]
    end
  end

  defp execute_instruction({:deletion, label}, box_content) do
    box_content
    |> Enum.filter(fn {other_label, _} ->
      label != other_label
    end)
  end
end
