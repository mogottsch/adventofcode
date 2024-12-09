const std = @import("std");
const testing = std.testing;
const parse = @import("parse.zig");
const part_1 = @import("part_1.zig");

const EXAMPLE_ANSWER_1: u64 = 18;

test "part 1 example" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parseFile(allocator, "example_1.txt");
    defer input.deinit();

    const result = part_1.run(allocator, input);
    try testing.expectEqual(EXAMPLE_ANSWER_1, result);
}

const REAL_ANSWER_1: u64 = 2454;

test "part 1 real" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parseFile(allocator, "input.txt");
    defer input.deinit();

    const result = part_1.run(allocator, input);
    try testing.expectEqual(REAL_ANSWER_1, result);
}
