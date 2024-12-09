const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const common = @import("common");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var antinodes = std.ArrayList(parse.Vector2D).init(allocator);
    defer antinodes.deinit();

    var iter = input.antennas.valueIterator();
    while (iter.next()) |antennas| {
        const new_antinodes = try calculateAntinodesForFrequency(allocator, antennas.items, input);
        defer allocator.free(new_antinodes);
        try antinodes.appendSlice(new_antinodes);
    }

    var unique_antinodes = std.AutoHashMap(parse.Vector2D, void).init(allocator);
    defer unique_antinodes.deinit();
    for (antinodes.items) |antinode| {
        try unique_antinodes.put(antinode, {});
    }

    return unique_antinodes.count();
}

fn calculateAntinodesForFrequency(
    allocator: std.mem.Allocator,
    antennas: []parse.Vector2D,
    input: parse.Input,
) ![]parse.Vector2D {
    var antinodes = std.ArrayList(parse.Vector2D).init(allocator);
    for (0..antennas.len) |i| {
        for (i + 1..antennas.len) |j| {
            const antinode = calculateAntinodesForAntennas(antennas[i], antennas[j], input);
            if (antinode.antinode_a) |n| try antinodes.append(n);
            if (antinode.antinode_b) |n| try antinodes.append(n);
        }
    }
    return antinodes.toOwnedSlice();
}

fn calculateAntinodesForAntennas(
    antenna_a: parse.Vector2D,
    antenna_b: parse.Vector2D,
    input: parse.Input,
) struct { antinode_a: ?parse.Vector2D, antinode_b: ?parse.Vector2D } {
    const direction = antenna_b.sub(antenna_a);

    const antinode_a = antenna_a.subSafe(direction, input) catch null;
    const antinode_b = antenna_b.addSafe(direction, input) catch null;

    return .{ .antinode_a = antinode_a, .antinode_b = antinode_b };
}
