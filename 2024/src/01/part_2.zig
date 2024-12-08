const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn runWithHashMap(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var map = std.AutoHashMap(u64, u64).init(allocator);
    defer map.deinit();

    for (input.right) |number| {
        const result = try map.getOrPut(number);
        if (!result.found_existing) {
            result.value_ptr.* = 0;
        }
        result.value_ptr.* += 1;
    }

    var similarity_score: u64 = 0;

    for (input.left) |number| {
        if (map.get(number)) |right_val| {
            similarity_score += right_val * number;
        }
    }

    return similarity_score;
}

pub fn runWithArray(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    _ = allocator;
    var counts = [_]u64{0} ** 100000;

    for (input.right) |number| {
        counts[number] += 1;
    }

    var similarity_score: u64 = 0;
    for (input.left) |number| {
        similarity_score += counts[number] * number;
    }

    return similarity_score;
}

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    return runWithArray(allocator, input);
}
