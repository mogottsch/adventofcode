const std = @import("std");
const common = @import("common");
const parse = @import("parse.zig");
const part_1 = @import("part_1.zig");
const part_2 = @import("part_2.zig");



pub fn main() !void {
    try common.run(
        parse.Input,
        u64,
        parse.parseFile,
        part_1.run,
        part_2.run,
    );
}
