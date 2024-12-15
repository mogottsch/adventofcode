const std = @import("std");
const common = @import("common");
const parse = @import("parse.zig");
const part_1 = @import("part_1.zig");

fn part_2_run(_: std.mem.Allocator, _: parse.Input) !u64 {
    return error.Unimplemented;
}


pub fn main() !void {
    try common.run(
        parse.Input,
        u64,
        parse.parseFile,
        part_1.run,
        part_2_run,
    );
}
