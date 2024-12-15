const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const part_1 = @import("part_1.zig");

const OFFSET: u64 = 10000000000000;

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    // add OFFSET to all systems
    for (input.systems) |*system| {
        system.p_x += OFFSET;
        system.p_y += OFFSET;
    }

    return part_1.findAndSumPrizes(allocator, input);
}
