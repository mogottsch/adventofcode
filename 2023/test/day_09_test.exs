import Day09.Day09

defmodule Day09.Day09Test do
  use ExUnit.Case, async: true
  @example_a_answer 114
  @part_a_answer 2005352194

  @example_b_answer 2
  @part_b_answer 

  @dir_path "lib/day_09/"

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
