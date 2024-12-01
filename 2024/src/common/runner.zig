const std = @import("std");
const argparse = @import("argparse.zig");

const testing = std.testing;
const info = std.log.info;

const ParseErrors = error{
    FileError,
    ParseError,
};

const PartErrors = error{
    Part1Error,
    Part2Error,
};

pub fn run(
    comptime T: type,
    comptime parse_file: fn (allocator: std.mem.Allocator, path: []const u8) anyerror!T,
    comptime run_part_1: fn (input: T) anyerror!i32,
    comptime run_part_2: fn (input: T) anyerror!i32,
) !void {
    const allocator = std.heap.page_allocator;

    const args = try argparse.parseArgs();
    const input = try parse_file(allocator, args.path);
    defer allocator.free(input);

    var result: ?i32 = null;
    switch (args.part) {
        .part_1 => {
            info("Running part 1", .{});
            result = try run_part_1(input);
        },
        .part_2 => {
            info("Running part 2", .{});
            result = try run_part_2(input);
        },
    }

    info("{d}", .{result.?});
}
