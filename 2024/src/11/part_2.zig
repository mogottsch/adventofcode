const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const part_1 = @import("part_1.zig");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var current_numbers = std.AutoHashMap(u64, u64).init(allocator);
    for (input.numbers.items) |number| {
        try part_1.putOrIncrementBy(&current_numbers, number, 1);
    }
    const result = try part_1.doBlinkNTimes(allocator, current_numbers, 75);
    return result;
}
