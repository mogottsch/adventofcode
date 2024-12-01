const std = @import("std");
const zbench = @import("zbench");
const path = @import("path.zig");

pub fn runBenchmarks(
    comptime ParseResult: type,
    allocator: std.mem.Allocator,
    parse_fn: fn (std.mem.Allocator, []const u8) anyerror!ParseResult,
    part1_fn: fn (std.mem.Allocator, ParseResult) anyerror!u32,
    part2_fn: fn (std.mem.Allocator, ParseResult) anyerror!u32,
) !void {
    const BenchContext = struct {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        var input: ParseResult = undefined;

        fn beforeAll() void {
            input = parse_fn(gpa.allocator(), "input.txt") catch unreachable;
        }

        fn afterAll() void {
            input.deinit();
        }

        fn benchParse(bench_allocator: std.mem.Allocator) void {
            var result = parse_fn(bench_allocator, "input.txt") catch unreachable;
            result.deinit();
        }

        fn benchPart1(bench_allocator: std.mem.Allocator) void {
            _ = part1_fn(bench_allocator, input) catch unreachable;
        }

        fn benchPart2(bench_allocator: std.mem.Allocator) void {
            _ = part2_fn(bench_allocator, input) catch unreachable;
        }

        fn deinit() void {
            const deinit_status = gpa.deinit();
            if (deinit_status == .leak) @panic("Memory leak detected");
        }
    };
    defer BenchContext.deinit();

    var bench = zbench.Benchmark.init(allocator, .{});
    defer bench.deinit();

    try bench.add("Parse Input", BenchContext.benchParse, .{});
    try bench.add("Part 1", BenchContext.benchPart1, .{
        .hooks = .{
            .before_all = BenchContext.beforeAll,
            .after_all = BenchContext.afterAll,
        },
    });
    try bench.add("Part 2", BenchContext.benchPart2, .{
        .hooks = .{
            .before_all = BenchContext.beforeAll,
            .after_all = BenchContext.afterAll,
        },
    });

    const stdout = std.io.getStdOut().writer();

    try stdout.writeAll("\n");
    try bench.run(stdout);
}
