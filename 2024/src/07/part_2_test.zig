const std = @import("std");
const testing = std.testing;
const parse = @import("parse.zig");
const part_2 = @import("part_2.zig");

const EXAMPLE_ANSWER_2: u64 = 11387;

test "part 2 example" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parseFile(allocator, "example_2.txt");
    defer input.deinit();

    const result = part_2.run(allocator, input);
    try testing.expectEqual(EXAMPLE_ANSWER_2, result);
}

const REAL_ANSWER_2: u64 = 362646859298554;

test "part 2 real" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parseFile(allocator, "input.txt");
    defer input.deinit();

    const result = part_2.run(allocator, input);
    try testing.expectEqual(REAL_ANSWER_2, result);
}
