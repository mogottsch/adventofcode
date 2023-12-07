defmodule Day07.Day07 do
  @card_value_shared %{
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "T" => 10,
    "Q" => 12,
    "K" => 13,
    "A" => 14
  }

  @type_value %{
    :high_card => 1,
    :one_pair => 2,
    :two_pairs => 3,
    :three_of_a_kind => 4,
    :full_house => 5,
    :four_of_a_kind => 6,
    :five_of_a_kind => 7
  }

  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def part_a(input) do
    input
    |> parse(:a)
    |> rank_and_sum_winnings()
  end

  def part_b(input) do
    input
    |> parse(:b)
    |> rank_and_sum_winnings()
  end

  defp rank_and_sum_winnings(hands) do
    hands
    |> Enum.sort_by(fn {{type, order}, _} ->
      {@type_value[type], order}
    end)
    |> Enum.with_index()
    |> Enum.map(fn {{_, bet}, index} ->
      bet * (index + 1)
    end)
    |> Enum.sum()
  end

  defp parse(input, task) do
    input
    |> Enum.map(&parse_line(&1, task))
  end

  defp parse_line(line, task) do
    line
    |> String.split(" ")
    |> List.to_tuple()
    |> then(fn {cards, bet} ->
      {parse_cards(cards, task), bet |> String.to_integer()}
    end)
  end

  defp parse_cards(cards, task) do
    cards
    |> String.split("", trim: true)
    |> then(fn cards ->
      {calculate_type(cards, task), calculate_order(cards, task)}
    end)
  end

  defp calculate_type(cards, :a) do
    cards
    |> count_occurrences()
    |> sort_map_values_desc()
    |> values_to_type()
  end

  defp calculate_type(cards, :b) do
    cards
    |> count_occurrences()
    |> extract_joker_value()
    |> then(fn {map, n_jokers} ->
      sort_map_values_desc(map) |> apply_joker(n_jokers)
    end) |> values_to_type()
  end

  defp count_occurrences(cards) do
    cards
    |> Enum.reduce(%{}, fn card, map ->
      Map.update(map, card, 1, &(&1 + 1))
    end)
  end

  defp sort_map_values_desc(map) do
    map
    |> Map.values()
    |> Enum.sort()
    |> Enum.reverse()
  end

  defp values_to_type(values) do
    case values do
      [5] -> :five_of_a_kind
      [4, 1] -> :four_of_a_kind
      [3, 1, 1] -> :three_of_a_kind
      [3, 2] -> :full_house
      [2, 2, 1] -> :two_pairs
      [2, 1, 1, 1] -> :one_pair
      _ -> :high_card
    end
  end

  defp extract_joker_value(map) do
    if not Map.has_key?(map, "J") do
      {map, 0}
    else
      {map |> Map.delete("J"), Map.get(map, "J")}
    end
  end

  defp apply_joker(_, 5) do
    [5]
  end

  defp apply_joker(values, n_jokers) do
    values |> increment_first_element(n_jokers)
  end

  defp increment_first_element([head | tail], n) do
    [head + n | tail]
  end

  defp calculate_order(cards, task) do
    cards
    |> Enum.map(&Map.get(@card_value_shared, &1, get_joker_value(task)))
  end

  defp get_joker_value(:a) do
    11
  end

  defp get_joker_value(:b) do
    1
  end
end
