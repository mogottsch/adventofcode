const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

const debug = @import("std").debug;
const Regex = @import("regex").Regex;

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u32 {
    _ = allocator;
    var total: u32 = 0;

    for (input.instructions) |instruction| {
        total += instruction.a * instruction.b;
    }

    return total;
}
