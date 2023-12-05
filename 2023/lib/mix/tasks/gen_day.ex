defmodule Mix.Tasks.GenDay do
  use Mix.Task

  @shortdoc "Creates new files for a given Advent of Code day"

  def run([day]) do
    Mix.Task.run("app.config")

    data = retrieve_data(day)

    day = String.pad_leading(day, 2, "0")
    dir_path = "lib/day_#{day}"
    file_path = "#{dir_path}/day_#{day}.ex"

    unless File.exists?(file_path) do
      File.mkdir_p!(dir_path)
      File.write!(file_path, day_module_template(day))
      IO.puts("Created Advent of Code files for day #{day}")
    else
      IO.puts("Files for day #{day} already exist")
    end

    IO.puts("Writing input and example files for day #{day}")
    File.write!(Path.join(dir_path, "example_a.txt"), data[:example_a])
    File.write!(Path.join(dir_path, "example_b.txt"), data[:example_b])
    File.write!(Path.join(dir_path, "input.txt"), data[:input])

    IO.puts("Writing tests for day #{day}")
    tests_path = "test"
    File.write!(Path.join(tests_path, "day_#{day}_test.exs"), day_test_template(day, data))
  end

  defp retrieve_data(day) do
    {:ok, cookie} = Application.fetch_env(:aoc, :cookie)

    if cookie == nil do
      IO.puts("No cookie set - using emtpy input and example files")

      %{
        input: "",
        example_a: "",
        example_b: "",
        part_a_answer: "",
        part_b_answer: "",
        example_a_answer: "",
        example_b_answer: ""
      }
    else
      IO.puts("Retrieving data for day #{day}")
      document = Scraper.get_day_html(day) |> HtmlParser.parse()

      example_a = HtmlParser.get_example(document, :a)
      example_b = HtmlParser.get_example(document, :b)

      example_a_answer = HtmlParser.get_example_answer(document, :a)
      example_b_answer = HtmlParser.get_example_answer(document, :b)

      part_a_answer = HtmlParser.get_input_answer(document, :a)
      part_b_answer = HtmlParser.get_input_answer(document, :b)

      input = Scraper.get_day_input(day)

      %{
        input: input,
        example_a: example_a,
        example_b: example_b,
        example_a_answer: example_a_answer,
        example_b_answer: example_b_answer,
        part_a_answer: part_a_answer,
        part_b_answer: part_b_answer
      }
    end
  end

  defp day_module_template(day) do
    """
    defmodule Day#{day}.Day#{day} do
      def part_a(input) do
        # Your code here
      end

      def part_b(input) do
        # Your code here
      end

      def parse_file(file_path) do
        # Your code here
      end
    end
    """
  end

  defp day_test_template(day, data) do
    example_a_answer = data[:example_a_answer]
    part_a_answer = data[:part_a_answer]
    example_b_answer = data[:example_b_answer]
    part_b_answer = data[:part_b_answer]

    """
    import Day#{day}.Day#{day}

    defmodule Day#{day}.Day#{day}Test do
      use ExUnit.Case, async: true
      @example_a_answer #{example_a_answer}
      @part_a_answer #{part_a_answer}

      @example_b_answer #{example_b_answer}
      @part_b_answer #{part_b_answer}

      @dir_path "lib/day_#{day}/"

      describe "part_a/1" do
        test "example" do
          assert @dir_path <> "example_a.txt" |> parse_file() |> part_a() == @example_a_answer
        end

        #{if data[:part_a_answer] == "" do
      "@tag :skip"
    end}
        test "input" do
          assert @dir_path <> "input.txt" |> parse_file() |> part_a() == @part_a_answer
        end
      end

      describe "part_b/1" do
        #{if data[:example_b_answer] == "" do
      "@tag :skip"
    end}
        test "example" do
          assert  @dir_path <> "example_b.txt" |> parse_file() |> part_b() == @example_b_answer
        end

        #{if data[:part_b_answer] == "" do
      "@tag :skip"
    end}
        test "input" do
          assert @dir_path <> "input.txt" |> parse_file() |> part_b() == @part_b_answer
        end
      end
    end
    """
  end
end
