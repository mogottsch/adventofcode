const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;

pub fn run(numbers: []i32) !i32 {
    var last_number: ?i32 = null;
    var n_increases: i32 = 0;
    for (numbers) |number| {
        if (last_number != null and number > last_number.?) {
            n_increases += 1;
        }
        last_number = number;
    }
    return n_increases;
}

const EXAMPLE_ANSWER_1: i32 = 7;

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const lines = try parse.parse_file(allocator, "example_1.txt");
    defer allocator.free(lines);

    const result = run(lines);
    try testing.expectEqual(result, EXAMPLE_ANSWER_1);
}
