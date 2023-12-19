defmodule Day19.Day19 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> List.to_tuple()
    |> then(fn {rules, parts} ->
      {rules |> parse_rules(), parts |> parse_parts()}
    end)
  end

  defp parse_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rule/1)
    |> Map.new()
  end

  defp parse_rule(rule) do
    rule
    |> String.replace("}", "")
    |> String.split("{")
    |> List.to_tuple()
    |> then(fn {name, rule} ->
      rule_parts = rule |> String.split(",")
      wild_card = rule_parts |> List.last()
      rule_parts = rule_parts |> List.delete_at(-1)
      {name, {rule_parts |> Enum.map(&parse_rule_part/1), wild_card}}
    end)
  end

  defp parse_rule_part(part) do
    pattern = ~r/(?P<attribute>[xmas])(?P<operator>[<>])(?P<value>\d+):(?P<next_rule>\w+)/

    Regex.named_captures(pattern, part)
    |> map_keys_to_atoms()
    |> Map.update!(:value, &String.to_integer/1)
  end

  defp parse_parts(parts) do
    parts |> String.split("\n", trim: true) |> Enum.map(&parse_part/1)
  end

  defp parse_part(part) do
    pattern = ~r/{x=(?P<x>\d+),m=(?P<m>\d+),a=(?P<a>\d+),s=(?P<s>\d+)}/

    Regex.named_captures(pattern, part)
    |> map_keys_to_atoms()
    |> Enum.map(fn {k, v} -> {k, String.to_integer(v)} end)
    |> Map.new()
  end

  defp map_keys_to_atoms(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.new()
  end

  def part_a({rules, parts}) do
    parts |> Enum.filter(&(apply_rules_until_finished(&1, rules) == "A")) |> sum_parts()
  end

  defp apply_rules_until_finished(part, rules, current_rule \\ "in")

  defp apply_rules_until_finished(_part, _rules, current_rule) when current_rule in ["R", "A"] do
    current_rule
  end

  defp apply_rules_until_finished(part, rules, current_rule) do
    {rule_parts, wild_card} = rules |> Map.get(current_rule)

    rule_parts
    |> Enum.find(&match_rule(part, &1))
    |> then(fn rule ->
      if rule != nil do
        rule.next_rule
      else
        wild_card
      end
    end)
    |> then(fn next_rule_label ->
      apply_rules_until_finished(part, rules, next_rule_label)
    end)
  end

  defp match_rule(part, rule) do
    rule_value = rule.value
    value = part[rule.attribute |> String.to_atom()]

    case rule.operator do
      "<" -> value < rule_value
      ">" -> value > rule_value
    end
  end

  defp sum_parts(parts) do
    parts
    |> Enum.map(fn part -> part |> Map.values() |> Enum.sum() end)
    |> Enum.sum()
  end

  def part_b({rules, _}) do
    reverse_map =
      rules |> build_reverse_map()

    rules
    |> find_initial_accepted_ranges()
    |> reverse_apply_rules_until_input(rules, reverse_map)
    |> Enum.map(fn {_, ranges} -> ranges |> count_possibilities() end)
    |> Enum.sum()
  end

  defp count_possibilities(ranges) do
    ranges
    |> Enum.map(fn {_, [min, max]} -> max - min + 1 end)
    |> Enum.product()
  end

  defp find_initial_accepted_ranges(rules) do
    rules
    |> Enum.reduce([], fn {rule_label, {rule_parts, wild_card}}, accepted_ranges ->
      accepted_ranges
      |> add_initial_wildcard_range(rule_label, rule_parts, wild_card)
      |> add_initial_rule_part_ranges(rule_label, rule_parts)
    end)
  end

  defp add_initial_wildcard_range(accepted_ranges, rule_label, rule_parts, wild_card) do
    if wild_card == "A" do
      new_ranges = make_unrestricted_ranges() |> make_ranges_reject_rule_parts(rule_parts)
      [{rule_label, new_ranges} | accepted_ranges]
    else
      accepted_ranges
    end
  end

  defp add_initial_rule_part_ranges(accepted_ranges, rule_label, rule_parts) do
    rule_parts
    |> Enum.with_index()
    |> Enum.filter(fn {part, _} -> part.next_rule == "A" end)
    |> Enum.reduce(accepted_ranges, fn {part, index}, accepted_ranges ->
      to_reject_rule_parts =
        rule_parts |> Enum.slice(0, index)

      new_ranges =
        make_unrestricted_ranges()
        |> make_ranges_accept_rule_part(part)
        |> make_ranges_reject_rule_parts(to_reject_rule_parts)

      [{rule_label, new_ranges} | accepted_ranges]
    end)
  end

  defp make_unrestricted_ranges() do
    %{
      :x => [1, 4000],
      :m => [1, 4000],
      :a => [1, 4000],
      :s => [1, 4000]
    }
  end

  defp make_ranges_reject_rule_parts(ranges, rule_parts) do
    rule_parts
    |> Enum.reduce(ranges, fn part, ranges ->
      attribute = part.attribute |> String.to_atom()
      value = part.value
      operator = part.operator

      ranges
      |> Map.update!(attribute, fn [min, max] ->
        make_range_reject_rule_parts(min, max, operator, value)
      end)
    end)
  end

  defp make_range_reject_rule_parts(min, max, operator, value) do
    case operator do
      ">" -> [min, min(value, max)]
      "<" -> [max(value, min), max]
    end
  end

  defp make_ranges_accept_rule_part(ranges, rule_part) do
    attribute = rule_part.attribute |> String.to_atom()
    value = rule_part.value
    operator = rule_part.operator

    ranges
    |> Map.update!(attribute, fn [min, max] ->
      make_range_accept_rule_part(min, max, operator, value)
    end)
  end

  defp make_range_accept_rule_part(min, max, operator, value) do
    case operator do
      ">" -> [max(value + 1, min), max]
      "<" -> [min, min(value - 1, max)]
    end
  end

  defp build_reverse_map(rules) do
    rules
    |> Enum.reduce(%{}, fn {rule_label, {rule_parts, wild_card}}, reverse_map ->
      reverse_map =
        reverse_map
        |> Map.update(wild_card, MapSet.new([rule_label]), fn referenced_by ->
          MapSet.put(referenced_by, rule_label)
        end)

      Enum.reduce(rule_parts, reverse_map, fn part, reverse_map ->
        reverse_map
        |> Map.update(part.next_rule, MapSet.new([rule_label]), fn referenced_by ->
          MapSet.put(referenced_by, rule_label)
        end)
      end)
    end)
  end

  defp reverse_apply_rules_until_input(accepted_ranges, rules, reverse_map) do
    if accepted_ranges |> Enum.all?(fn {label, _} -> label == "in" end) do
      accepted_ranges
    else
      accepted_ranges
      |> reverse_apply_rules(rules, reverse_map)
      |> reverse_apply_rules_until_input(rules, reverse_map)
    end
  end

  defp reverse_apply_rules(accepted_ranges, rules, reverse_map) do
    accepted_ranges
    |> Enum.map(fn {rule_label, ranges} ->
      if rule_label == "in" do
        [{rule_label, ranges}]
      else
        referenced_by = reverse_map |> Map.get(rule_label, MapSet.new())

        referenced_by
        |> Enum.map(fn other_rule_label ->
          other_rule = rules |> Map.get(other_rule_label)

          ranges
          |> make_ranges_point_to_label(rule_label, other_rule)
          |> Enum.map(fn ranges -> {other_rule_label, ranges} end)
        end)
      end
      |> List.flatten()
    end)
    |> List.flatten()
  end

  defp make_ranges_point_to_label(ranges, rule_label, {rule_parts, wild_card}) do
    new_ranges_list = []

    new_ranges_list
    |> add_wildcard_range(rule_label, rule_parts, wild_card, ranges)
    |> add_rule_part_ranges(rule_label, rule_parts, ranges)
  end

  defp add_wildcard_range(new_ranges_list, rule_label, rule_parts, wild_card, ranges) do
    if wild_card == rule_label do
      new_ranges = ranges |> make_ranges_reject_rule_parts(rule_parts)
      [new_ranges | new_ranges_list]
    else
      new_ranges_list
    end
  end

  defp add_rule_part_ranges(new_ranges_list, rule_label, rule_parts, ranges) do
    rule_parts
    |> Enum.with_index()
    |> Enum.filter(fn {part, _} -> part.next_rule == rule_label end)
    |> Enum.reduce(new_ranges_list, fn {part, index}, new_ranges_list ->
      to_reject_rule_parts =
        rule_parts |> Enum.slice(0, index)

      new_ranges =
        ranges
        |> make_ranges_accept_rule_part(part)
        |> make_ranges_reject_rule_parts(to_reject_rule_parts)

      [new_ranges | new_ranges_list]
    end)
  end
end
