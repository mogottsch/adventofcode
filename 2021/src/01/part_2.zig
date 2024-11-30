const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;

pub fn run(numbers: []i32) !i32 {
    const n_lines = numbers.len;
    if (n_lines < 4) {
        return 0;
    }

    var n_increases: i32 = 0;
    var last_sum: ?i32 = null;

    var i: usize = 2;
    while (i < n_lines) : (i += 1) {
        const sum = numbers[i] + numbers[i - 1] + numbers[i - 2];
        if (last_sum != null and sum > last_sum.?) {
            n_increases += 1;
        }
        last_sum = sum;
    }

    return n_increases;
}

const EXAMPLE_ANSWER_2: i32 = 5;

test "part 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const numbers = try parse.parse_file(allocator, "example_2.txt");
    defer allocator.free(numbers);

    const result = run(numbers);
    try testing.expectEqual(result, EXAMPLE_ANSWER_2);
}
