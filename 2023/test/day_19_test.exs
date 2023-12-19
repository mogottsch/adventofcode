import Day19.Day19

defmodule Day19.Day19Test do
  use ExUnit.Case, async: true
  @example_a_answer 19114
  @part_a_answer 398527

  @example_b_answer 167409079868000
  @part_b_answer 133973513090020

  @dir_path "lib/day_19/"

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

    
    test "input" do
      assert @dir_path <> "input.txt" |> parse_file() |> part_b() == @part_b_answer
    end
  end
end
