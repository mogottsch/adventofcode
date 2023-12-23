import Day23.Day23

defmodule Day23.Day23Test do
  use ExUnit.Case, async: true
  @example_a_answer 94
  @part_a_answer 

  @example_b_answer 
  @part_b_answer 

  @dir_path "lib/day_23/"

  describe "part_a/1" do
    test "example" do
      assert @dir_path <> "example_a.txt" |> parse_file() |> part_a() == @example_a_answer
    end

    @tag :skip
    test "input" do
      assert @dir_path <> "input.txt" |> parse_file() |> part_a() == @part_a_answer
    end
  end

  describe "part_b/1" do
    @tag :skip
    test "example" do
      assert  @dir_path <> "example_b.txt" |> parse_file() |> part_b() == @example_b_answer
    end

    @tag :skip
    test "input" do
      assert @dir_path <> "input.txt" |> parse_file() |> part_b() == @part_b_answer
    end
  end
end
