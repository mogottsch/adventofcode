import Day07.Day07

defmodule Day07.Day07Test do
  use ExUnit.Case, async: true
  @example_a_answer 6440
  @part_a_answer 250951660

  @example_b_answer 5905
  @part_b_answer 251481660

  @dir_path "lib/day_07/"

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
