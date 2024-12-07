const std = @import("std");
const testing = std.testing;
const parse = @import("parse.zig");
const part_1 = @import("part_1.zig");

const EXAMPLE_ANSWER_1: u32 = 41;

test "part 1 example" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parse_file(allocator, "example_1.txt");
    defer input.deinit();

    const result = part_1.run(allocator, input);
    try testing.expectEqual(EXAMPLE_ANSWER_1, result);
}

const REAL_ANSWER_1: u32 = 5551;

test "part 1 real" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parse_file(allocator, "input.txt");
    defer input.deinit();

    const result = part_1.run(allocator, input);
    try testing.expectEqual(REAL_ANSWER_1, result);
}
