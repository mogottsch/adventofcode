const std = @import("std");
const testing = std.testing;
const info = std.log.info;

const common = @import("common");
const parse = @import("parse.zig");
const part_1 = @import("part_1.zig");
const part_2 = @import("part_2.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try common.argparse.parseArgs();
    const input = try parse.parse_file(allocator, args.path);
    defer allocator.free(input);

    var result: ?i32 = null;
    switch (args.part) {
        .part_1 => {
            info("Running part 1", .{});
            result = try part_1.run(input);
        },
        .part_2 => {
            info("Running part 2", .{});
            result = part_2.run(input);
        },
    }

    info("{d}", .{result.?});
}
