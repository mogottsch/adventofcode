# 2023 Advent of Code Solutions Elixir

**Disclaimer:** This is my first time writing elixir.

## Mix tasks
### Generate new day
```
mix gen_day {day}
```

### Run day
```
mix run_day {day} {a|b} {example|input} 
```

### Benchmark
```
mix benchmark
```


## Benchmarks
<!-- BENCHMARKS_START -->
| day | parse | part a | part b | total |
|-----|-------|--------|--------|-------|
| 01 | 137.17 µs ⚪️ | 3.80 ms 🔵 | 552.12 ms 🔵 | 556.06 ms 🔵 |
| 02 | 76.76 µs ⚪️ | 879.58 µs ⚪️ | 996.28 µs ⚪️ | 1.95 ms 🔵 |
| 03 | 2.67 ms 🔵 | 1.03 s 🔴 | 1.72 s 🔴 | 2.75 s 🔴 |
| 04 | 4.40 µs ⚪️ | 205.05 µs ⚪️ | 2.33 ms 🔵 | 2.54 ms 🔵 |
| 05 | 30.03 µs ⚪️ | 182.22 µs ⚪️ | 333.66 µs ⚪️ | 545.91 µs ⚪️ |
| 06 | 3.84 µs ⚪️ | 4.33 µs ⚪️ | 71.31 µs ⚪️ | 79.48 µs ⚪️ |
| 07 | 136.40 µs ⚪️ | 3.53 ms 🔵 | 3.41 ms 🔵 | 7.08 ms 🔵 |
| 08 | 1.74 ms 🔵 | 16.50 ms 🔵 | 281.33 ms 🔵 | 299.57 ms 🔵 |
<!-- BENCHMARKS_END -->


## Inspiration

The mix tasks are inspired by some awesome repositories:
- [mhanberg/advent-of-code-elixir-starter](https://github.com/mhanberg/advent-of-code-elixir-starter)
- [staylorwr/elixir_aoc](https://github.com/staylorwr/elixir_aoc)
- [gahjelle/advent_of_code](https://github.com/gahjelle/advent_of_code)
