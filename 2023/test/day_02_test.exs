import Day02.Day02

defmodule Day02.Day02Test do
  use ExUnit.Case, async: true
  @example_a_answer 8
  @part_a_answer 3059

  @example_b_answer 2286
  @part_b_answer 65371

  @dir_path "lib/day_02/"

  describe "" do
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
