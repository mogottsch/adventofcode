import Day20.Day20

defmodule Day20.Day20Test do
  use ExUnit.Case, async: true
  @example_a_answer 11687500
  @part_a_answer 886701120

  @example_b_answer 
  @part_b_answer 228134431501037

  @dir_path "lib/day_20/"

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
