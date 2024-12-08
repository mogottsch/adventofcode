const std = @import("std");
const testing = std.testing;
const parse = @import("parse.zig");
const part_2 = @import("part_2.zig");

const EXAMPLE_ANSWER_2: u64 = 31;

test "part 2 example" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parse_file(allocator, "example_2.txt");
    defer input.deinit();

    const result = part_2.run(allocator, input);
    try testing.expectEqual(result, EXAMPLE_ANSWER_2);
}

const REAL_ANSWER_2: u64 = 27384707;

test "part 2 real" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parse_file(allocator, "input.txt");
    defer input.deinit();

    const result = part_2.run(allocator, input);
    try testing.expectEqual(result, REAL_ANSWER_2);
}
