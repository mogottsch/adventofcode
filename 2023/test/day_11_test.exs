import Day11.Day11

defmodule Day11.Day11Test do
  use ExUnit.Case, async: true
  @example_a_answer 374
  @part_a_answer 10292708

  @part_b_answer 790194712336

  @dir_path "lib/day_11/"

  describe "part_a/1" do
    test "example" do
      assert @dir_path <> "example_a.txt" |> parse_file() |> part_a() == @example_a_answer
    end

    
    test "input" do
      assert @dir_path <> "input.txt" |> parse_file() |> part_a() == @part_a_answer
    end
  end

  describe "part_b/1" do
    
    
    test "input" do
      assert @dir_path <> "input.txt" |> parse_file() |> part_b() == @part_b_answer
    end
  end
end
