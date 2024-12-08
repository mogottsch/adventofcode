const std = @import("std");
const parse = @import("parse.zig");

pub fn run(_: std.mem.Allocator, input: parse.Input) !u64 {
    std.mem.sort(u64, input.left, {}, comptime std.sort.asc(u64));
    std.mem.sort(u64, input.right, {}, comptime std.sort.asc(u64));

    var diff_sum: u64 = 0;

    for (input.left, input.right) |left, right| {
        const diff = @as(i32, @intCast(right)) - @as(i32, @intCast(left));
        diff_sum += @abs(diff);
    }

    return diff_sum;
}
