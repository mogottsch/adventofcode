defmodule Day20.Day20 do
  def parse_file(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Map.new()
    |> fill_initial_conjunction_module_states()
    |> add_output_modules()
  end

  defp parse_line(line) do
    line
    |> String.split(" -> ")
    |> List.to_tuple()
    |> then(fn {typeAndLabel, targets} ->
      {type, label} = typeAndLabel |> parse_type_and_label()
      children = targets |> parse_children()
      state = type |> create_initial_state()
      {label, {type, state, children}}
    end)
  end

  # first char is type, rest is label
  defp parse_type_and_label(typeAndLabel) do
    if typeAndLabel == "broadcaster" do
      {:broadcaster, "broadcaster"}
    else
      [typeChar | label] =
        typeAndLabel
        |> String.graphemes()

      {typeChar |> String.to_atom(), label |> Enum.join()}
    end
  end

  defp parse_children(targets), do: targets |> String.split(", ")

  defp create_initial_state(:%), do: :off
  defp create_initial_state(:&), do: %{}
  defp create_initial_state(:broadcaster), do: nil

  defp fill_initial_conjunction_module_states(map) do
    reverse_map =
      map
      |> build_reverse_map()

    map
    |> Enum.map(fn {label, {type, state, children}} ->
      if type != :& do
        {label, {type, state, children}}
      else
        {label,
         {
           type,
           reverse_map |> Map.get(label) |> make_empty_conjuction_module_state(),
           children
         }}
      end
    end)
    |> Map.new()
  end

  defp make_empty_conjuction_module_state(labels) do
    labels
    |> Enum.map(fn label -> {label, :low} end)
    |> Map.new()
  end

  defp build_reverse_map(map) do
    map
    |> Enum.reduce(%{}, fn {label, {_, _, children}}, reverse_map ->
      children
      |> Enum.reduce(reverse_map, fn child, reverse_map ->
        reverse_map
        |> Map.update(child, MapSet.new([label]), fn state ->
          state |> MapSet.put(label)
        end)
      end)
    end)
  end

  defp add_output_modules(map) do
    map
    |> Enum.reduce(%{}, fn {label, {type, state, children}}, new_map ->
      children
      |> Enum.reduce(new_map, fn child, new_map ->
        if new_map |> Map.has_key?(child) do
          new_map
        else
          new_map |> Map.put(child, {:output, nil, []})
        end
      end)
      |> Map.put(label, {type, state, children})
    end)
  end

  def part_a(initial_state) do
    n_button_presses = 1000

    initial_state
    # add output module
    |> push_button_n_times(n_button_presses)
    |> Map.values()
    |> Enum.product()
  end

  defp push_button_n_times(state, n, signal_counts \\ %{})

  defp push_button_n_times(_state, 0, signal_counts) do
    signal_counts
  end

  defp push_button_n_times(state, n, signal_counts) do
    {new_state, signal_counts} =
      state
      |> push_button(signal_counts)

    push_button_n_times(
      new_state,
      n - 1,
      signal_counts
    )
  end

  defp push_button(state, signal_counts) do
    state
    |> get_broadcaster_signals()
    |> process_signals_until_stable(state, signal_counts)
  end

  defp get_broadcaster_signals(initial_state) do
    initial_state
    |> Map.get("broadcaster")
    |> then(fn {_, _, children} ->
      children
      |> Enum.map(fn child -> {"broadcaster", child, :low} end)
    end)
  end

  defp process_signals_until_stable(signals, state, signal_counts)
       when length(signals) == 0 do
    {state, signal_counts |> Map.update(:low, 1, &(&1 + 1))}
  end

  defp process_signals_until_stable(signals, state, signal_counts) do
    [signal | remaining_signals] = signals
    {_, _, signal_type} = signal
    signal_counts = signal_counts |> Map.update(signal_type, 1, &(&1 + 1))

    {new_signals, state} =
      signal |> process_signal(state)

    process_signals_until_stable(
      remaining_signals ++ new_signals,
      state,
      signal_counts
    )
  end

  defp process_signal({from_label, to_label, signal}, state) do
    module = state |> Map.get(to_label)

    if module == nil do
      throw({:no_module, to_label})
    end

    {type, _, children} = module

    {new_signals, new_state} =
      case type do
        :% -> process_signal_for_flip_flop_module(module, signal, to_label)
        :& -> process_signal_for_conjunction_module(module, signal, from_label, to_label)
        # untyped module, do nothing
        :output -> {[], signal}
      end

    new_module = {type, new_state, children}
    {new_signals, state |> Map.put(to_label, new_module)}
  end

  defp process_signal_for_flip_flop_module(module, signal, label) do
    {_, state, children} = module

    case {signal, state} do
      {:high, _} -> {[], state}
      {:low, :off} -> {children |> Enum.map(fn child -> {label, child, :high} end), :on}
      {:low, :on} -> {children |> Enum.map(fn child -> {label, child, :low} end), :off}
    end
  end

  defp process_signal_for_conjunction_module(module, signal, from_label, to_label) do
    {_, state, children} = module

    new_state = state |> Map.update!(from_label, fn _ -> signal end)

    # if all values are high, then we send a low signal, else we send a high signal
    if new_state |> Map.values() |> Enum.all?(&(&1 == :high)) do
      {children |> Enum.map(fn child -> {to_label, child, :low} end), new_state}
    else
      {children |> Enum.map(fn child -> {to_label, child, :high} end), new_state}
    end
  end

  def part_b(initial_state) do
    ["bp", "xc", "th", "pd"]
    |> Enum.map(fn label -> push_until_value_is(initial_state, label, :high) end)
    |> lcm_list()
  end

  defp push_until_value_is(state, label, value, iteration \\ 1) do
    {stopped, state} = state |> push_button_and_stop_if_value_is(label, value)

    if stopped == :stopped do
      iteration
    else
      push_until_value_is(state, label, value, iteration + 1)
    end
  end

  defp push_button_and_stop_if_value_is(state, label, value) do
    state
    |> get_broadcaster_signals()
    |> process_signals_until_stable_or_until_value_is(state, label, value)
  end

  defp process_signals_until_stable_or_until_value_is(signals, state, _label, _value)
       when length(signals) == 0 do
    {:not_stopped, state}
  end

  defp process_signals_until_stable_or_until_value_is(signals, state, label, value) do
    [signal | remaining_signals] = signals

    {new_signals, state} =
      signal |> process_signal(state)

    val =
      state
      |> Map.get("zh")
      |> then(fn {_, state, _} -> state end)
      |> Map.get(label)

    if val == value do
      {:stopped, state}
    else
      process_signals_until_stable_or_until_value_is(
        remaining_signals ++ new_signals,
        state,
        label,
        value
      )
    end
  end

  defp lcm(a, b) do
    (a * b / gcd(a, b)) |> round()
  end

  defp gcd(a, 0), do: a
  defp gcd(a, b), do: gcd(b, rem(a, b))

  def lcm_list([head | tail]) do
    Enum.reduce(tail, head, &lcm/2)
  end
end
