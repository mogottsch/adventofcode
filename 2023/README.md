# 2023 Advent of Code Solutions Elixir


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
| 01 | 37.16 µs ⚪️ | 3.50 ms 🔵 | 483.61 ms 🔵 | 487.15 ms 🔵 |
| 02 | 14.88 µs ⚪️ | 777.40 µs ⚪️ | 817.84 µs ⚪️ | 1.61 ms 🔵 |
| 03 | 1.14 ms 🔵 | 889.31 ms 🔵 | 1.00 s 🔴 | 1.89 s 🔴 |
| 04 | 3.84 µs ⚪️ | 97.78 µs ⚪️ | 1.57 ms 🔵 | 1.67 ms 🔵 |
<!-- BENCHMARKS_END -->


## Inspiration

The mix tasks are inspired by some awesome repositories:
- [mhanberg/advent-of-code-elixir-starter](https://github.com/mhanberg/advent-of-code-elixir-starter)
- [staylorwr/elixir_aoc](https://github.com/staylorwr/elixir_aoc)
- [gahjelle/advent_of_code](https://github.com/gahjelle/advent_of_code)
