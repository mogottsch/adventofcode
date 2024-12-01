const std = @import("std");
const parse = @import("parse.zig");

pub fn run(input: parse.Input) !u32 {
    std.mem.sort(i32, input.left, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, input.right, {}, comptime std.sort.asc(i32));

    var diff_sum: u32 = 0;

    for (input.left, input.right) |left, right| {
        diff_sum += @abs(right - left);
    }

    return diff_sum;
}
