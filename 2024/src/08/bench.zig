const std = @import("std");
const bench = @import("common").bench;
const parse = @import("parse.zig");
const part_1 = @import("part_1.zig");
const part_2 = @import("part_2.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    try bench.runBenchmarks(
        parse.Input,
        gpa.allocator(),
        parse.parse_file,
        part_1.run,
        part_2.run,
    );
}
