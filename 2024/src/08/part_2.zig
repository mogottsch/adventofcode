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
            var pair_antinodes = try calculateAntinodesForAntennas(allocator, antennas[i], antennas[j], input);
            defer pair_antinodes.deinit();
            try antinodes.appendSlice(pair_antinodes.items);
        }
    }

    return antinodes.toOwnedSlice();
}

fn calculateAntinodesForAntennas(
    allocator: std.mem.Allocator,
    antenna_a: parse.Vector2D,
    antenna_b: parse.Vector2D,
    input: parse.Input,
) !std.ArrayList(parse.Vector2D) {
    var antinodes = std.ArrayList(parse.Vector2D).init(allocator);
    errdefer antinodes.deinit();

    const direction = antenna_b.sub(antenna_a);
    const norm_direction = normalizeVector(direction);

    var current = antenna_a;
    while (true) {
        try antinodes.append(current);
        current = current.subSafe(norm_direction, input) catch break;
    }

    current = antenna_b;
    while (true) {
        try antinodes.append(current);
        current = current.addSafe(norm_direction, input) catch break;
    }

    return antinodes;
}

fn normalizeVector(vector: parse.Vector2D) parse.Vector2D {
    const gcd: i32 = @intCast(std.math.gcd(@abs(vector.x), @abs(vector.y)));
    return .{
        .x = @divExact(vector.x, gcd),
        .y = @divExact(vector.y, gcd),
    };
}
