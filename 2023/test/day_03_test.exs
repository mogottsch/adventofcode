import Day03.Day03

defmodule Day03.Day03Test do
  use ExUnit.Case, async: true
  @example_a_answer 4361
  @part_a_answer 550064

  @example_b_answer 467835
  @part_b_answer 85010461

  @dir_path "lib/day_03/"

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
