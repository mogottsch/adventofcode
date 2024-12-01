const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u32 {
    var map = std.AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    for (input.right) |number| {
        const result = try map.getOrPut(number);
        if (!result.found_existing) {
            result.value_ptr.* = 0;
        }
        result.value_ptr.* += 1;
    }

    var similarity_score: u32 = 0;

    for (input.left) |number| {
        if (map.get(number)) |right_val| {
            similarity_score += right_val * number;
        }
    }

    return similarity_score;
}
