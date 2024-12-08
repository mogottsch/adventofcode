## Run solution
```bash
zig build run-1 -- part_1 input.txt
```

## Run test

**For day 1**
```bash
zig build test-1 --summary all
```
or with `watchexec`
```bash
watchexec -c -e zig "zig build test-1 --summary all"
```

**For all days:**
```bash
zig build test --summary all
```
## Generate day
**For day 1**
```bash
zig build generate -- 1
```


## Run benchmark
**For day 1**
```bash
zig build bench-1
```

# Todos
- [ ] handle multiple code blocks properly
- [ ] fix day 6 part 2
