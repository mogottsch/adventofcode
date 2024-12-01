const std = @import("std");
const testing = std.testing;
const parse = @import("parse.zig");

pub fn run(input: parse.Input) !u32 {
    // std.debug.print("input left: {any}\n", .{input.left});
    // std.debug.print("input right: {any}\n", .{input.right});

    std.mem.sort(i32, input.left, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, input.right, {}, comptime std.sort.asc(i32));

    // std.debug.print("input left: {any}\n", .{input.left});
    // std.debug.print("input right: {any}\n", .{input.right});

    var diff_sum: u32 = 0;

    for (input.left, input.right) |left, right| {
        diff_sum += @abs(right - left);
    }

    return diff_sum;
}

const EXAMPLE_ANSWER_1: i32 = 11;

test "part 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var input = try parse.parse_file(allocator, "example_1.txt");
    defer input.deinit();

    const result = run(input);
    try testing.expectEqual(result, EXAMPLE_ANSWER_1);
}
