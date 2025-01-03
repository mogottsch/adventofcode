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

### Run tests with hot code reload
```
mix test.watch ./test/day_{day}_test.exs
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
| 09 | 352.35 µs ⚪️ | 2.31 ms 🔵 | 2.41 ms 🔵 | 5.08 ms 🔵 |
| 10 | 3.25 ms 🔵 | 3.25 s 🔴 | 5.06 s 🔴 | 8.32 s 🔴 |
| 11 | 4.08 ms 🔵 | 30.64 ms 🔵 | 29.35 ms 🔵 | 64.07 ms 🔵 |
| 14 | 1.13 ms 🔵 | 4.85 ms 🔵 | 5.11 s 🔴 | 5.12 s 🔴 |
| 15 | 295.01 µs ⚪️ | 367.64 µs ⚪️ | 3.93 ms 🔵 | 4.59 ms 🔵 |
| 16 | 1.41 ms 🔵 | 21.55 ms 🔵 | 5.83 s 🔴 | 5.86 s 🔴 |
| 17 | 2.11 ms 🔵 | 1.88 s 🔴 | 6.54 s 🔴 | 8.42 s 🔴 |
| 18 | 229.60 µs ⚪️ | 786.97 µs ⚪️ | 150.31 s 🔴 | 150.31 s 🔴 |
| 19 | 406.51 µs ⚪️ | 5.46 ms 🔵 | 5.69 ms 🔵 | 11.56 ms 🔵 |
| 20 | 350.18 µs ⚪️ | 22.07 ms 🔵 | 399.83 ms 🔵 | 422.25 ms 🔵 |
| 23 | 1.35 ms 🔵 | 1.09 s 🔴 | 18.67 s 🔴 | 19.76 s 🔴 |
<!-- BENCHMARKS_END -->


## Inspiration

The mix tasks are inspired by some awesome repositories:
- [mhanberg/advent-of-code-elixir-starter](https://github.com/mhanberg/advent-of-code-elixir-starter)
- [staylorwr/elixir_aoc](https://github.com/staylorwr/elixir_aoc)
- [gahjelle/advent_of_code](https://github.com/gahjelle/advent_of_code)
