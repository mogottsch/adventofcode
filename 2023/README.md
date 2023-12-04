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
| day | parse       | part a       | part b       | total        |
|-----|-------------|--------------|--------------|--------------|
| 01  | 37.16 µs ⚪️ | 3.56 ms 🔵   | 473.53 ms 🔵 | 477.13 ms 🔵 |
| 02  | 14.88 µs ⚪️ | 787.98 µs ⚪️ | 837.84 µs ⚪️ | 1.64 ms 🔵   |
| 03  | 1.30 ms 🔵  | 900.90 ms 🔵 | 988.02 ms 🔵 | 1.89 s 🔴    |
| 04  | 3.84 µs ⚪️  | 100.64 µs ⚪️ | 1.57 ms 🔵   | 1.67 ms 🔵   |
<!-- BENCHMARKS_END -->


## Inspiration

The mix tasks are inspired by some awesome repositories:
- [mhanberg/advent-of-code-elixir-starter]
- [staylorwr/elixir_aoc]
- [gahjelle/advent_of_code]
