const std = @import("std");
const testing = std.testing;
const parse = @import("parse.zig");
const part_1 = @import("part_1.zig");
const zbench = @import("zbench");

const EXAMPLE_ANSWER_1: u32 = 11;

test "part 1 example" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parse_file(allocator, "example_1.txt");
    defer input.deinit();

    const result = part_1.run(allocator, input);
    try testing.expectEqual(result, EXAMPLE_ANSWER_1);
}

const REAL_ANSWER_1: u32 = 1341714;

test "part 1 real" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parse_file(allocator, "input.txt");
    defer input.deinit();

    const result = part_1.run(allocator, input);
    try testing.expectEqual(result, REAL_ANSWER_1);
}

fn run_real(allocator: std.mem.Allocator) void {
    std.debug.print("Running real...\n", .{});
    var input = parse.parse_file(allocator, "input.txt") catch unreachable;
    std.debug.print("Parsed input.\n", .{});
    defer input.deinit();

    std.debug.print("Running part 1...\n", .{});
    const result = part_1.run(allocator, input) catch unreachable;
    std.debug.print("Part 1 result: {}\n", .{result});
}

test "part 1 bench" {
    var bench = zbench.Benchmark.init(std.testing.allocator, .{});
    defer bench.deinit();
    std.debug.print("Running benchmark...\n", .{});
    try bench.add("My Benchmark", run_real, .{ .max_iterations = 1, .time_budget_ns = 2e9 });
    std.debug.print("Benchmark complete.\n", .{});
    try bench.run(std.io.getStdOut().writer());
}
