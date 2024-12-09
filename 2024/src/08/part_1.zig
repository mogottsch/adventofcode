const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const common = @import("common");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var unique_antinodes = std.AutoHashMap(parse.Vector2D, void).init(allocator);
    unique_antinodes.ensureTotalCapacity(@intCast(input.grid.len * input.grid[0].len)) catch {};

    defer unique_antinodes.deinit();

    var iter = input.antennas.valueIterator();
    while (iter.next()) |antennas| {
        try calculateAntinodesForFrequency(antennas.items, input, &unique_antinodes);
    }

    return unique_antinodes.count();
}

fn calculateAntinodesForFrequency(
    antennas: []parse.Vector2D,
    input: parse.Input,
    unique_antinodes: *std.AutoHashMap(parse.Vector2D, void),
) !void {
    for (0..antennas.len) |i| {
        for (i + 1..antennas.len) |j| {
            try calculateAntinodesForAntennas(
                antennas[i],
                antennas[j],
                input,
                unique_antinodes,
            );
        }
    }
}

fn calculateAntinodesForAntennas(
    antenna_a: parse.Vector2D,
    antenna_b: parse.Vector2D,
    input: parse.Input,
    unique_antinodes: *std.AutoHashMap(parse.Vector2D, void),
) !void {
    const direction = antenna_b.sub(antenna_a);

    const antinode_a = antenna_a.subSafe(direction, input) catch null;
    const antinode_b = antenna_b.addSafe(direction, input) catch null;

    if (antinode_a) |antinode| unique_antinodes.putAssumeCapacity(antinode, {});
    if (antinode_b) |antinode| unique_antinodes.putAssumeCapacity(antinode, {});
}
