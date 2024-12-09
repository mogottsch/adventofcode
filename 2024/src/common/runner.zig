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
    comptime InputType: type,
    comptime ReturnType: type,
    comptime parseFile: fn (allocator: std.mem.Allocator, path: []const u8) anyerror!InputType,
    comptime run_part_1: fn (allocator: std.mem.Allocator, input: InputType) anyerror!ReturnType,
    comptime run_part_2: fn (allocator: std.mem.Allocator, input: InputType) anyerror!ReturnType,
) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try argparse.parseArgs(allocator);
    var input = try parseFile(allocator, args.path);
    defer input.deinit();

    var result: ?ReturnType = null;
    switch (args.part) {
        .part_1 => {
            info("Running part 1", .{});
            result = try run_part_1(allocator, input);
        },
        .part_2 => {
            info("Running part 2", .{});
            result = try run_part_2(allocator, input);
        },
    }

    info("{d}", .{result.?});
}
