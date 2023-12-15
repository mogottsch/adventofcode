import Day15.Day15

defmodule Day15.Day15Test do
  use ExUnit.Case, async: true
  @example_a_answer 1320
  @part_a_answer 503154

  @example_b_answer 145
  @part_b_answer 

  @dir_path "lib/day_15/"

  describe "part_a/1" do
    test "example" do
      assert @dir_path <> "example_a.txt" |> parse_file() |> part_a() == @example_a_answer
    end

    
    test "input" do
      assert @dir_path <> "input.txt" |> parse_file() |> part_a() == @part_a_answer
    end
  end

  describe "part_b/1" do
    
    test "example" do
      assert  @dir_path <> "example_b.txt" |> parse_file() |> part_b() == @example_b_answer
    end

    @tag :skip
    test "input" do
      assert @dir_path <> "input.txt" |> parse_file() |> part_b() == @part_b_answer
    end
  end
end
