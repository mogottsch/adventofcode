const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u32 {
    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    for (input.right) |number| {
        const maybe_current = map.get(number);
        const current = if (maybe_current != null) maybe_current.? else 0;

        try map.put(number, current + 1);
    }
    // var it = map.iterator();
    // while (it.next()) |entry| {
    //     std.debug.print("key: {d}, value: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    // }

    var similarity_score: u32 = 0;

    for (input.left) |number| {
        const maybe_right_val = map.get(number);
        if (maybe_right_val == null) continue;

        const right_val = maybe_right_val.?;

        similarity_score += right_val * number;
    }

    return similarity_score;
}
