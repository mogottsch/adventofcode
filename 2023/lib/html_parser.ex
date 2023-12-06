defmodule HtmlParser do
  def parse(body) do
    {:ok, document} = Floki.parse_document(body)
    document
  end

  def get_example(document, part) do
    Floki.find(document, "article.day-desc pre code")
    |> then(fn list ->
      case part do
        :a ->
          List.first(list)

        :b ->
          Enum.at(list, 1)

        _ ->
          raise "Invalid part"
      end
    end)
    |> Floki.text()
  end

  def get_example_answer(document, part) do
    Floki.find(document, "article.day-desc")
    |> then(fn list ->
      case part do
        :a ->
          List.first(list)

        :b ->
          Enum.at(list, 1)

        _ ->
          raise "Invalid part"
      end
    end)
    |> Floki.find("code em")
    |> List.last()
    |> Floki.text()
  end

  def get_input_answer(document, part) do
    Floki.find(document, "p")
    |> Enum.filter(fn p -> Floki.text(p) |> String.contains?("Your puzzle answer was") end)
    |> then(fn list ->
      case part do
        :a ->
          List.first(list)

        :b ->
          Enum.at(list, 1)

        _ ->
          raise "Invalid part"
      end
    end)
    |> Floki.text()
    |> String.split(" ")
    |> List.last()
    |> String.replace(".", "")
  end
end
