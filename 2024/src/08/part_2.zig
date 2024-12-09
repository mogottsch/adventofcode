const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const common = @import("common");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var unique_antinodes = std.AutoHashMap(parse.Vector2D, void).init(allocator);
    defer unique_antinodes.deinit();

    var iter = input.antennas.valueIterator();
    while (iter.next()) |antennas| {
        try calculateAntinodesForFrequency(allocator, antennas.items, input, &unique_antinodes);
    }

    return unique_antinodes.count();
}

fn calculateAntinodesForFrequency(
    _: std.mem.Allocator,
    antennas: []parse.Vector2D,
    input: parse.Input,
    unique_antinodes: *std.AutoHashMap(parse.Vector2D, void),
) !void {
    for (0..antennas.len) |i| {
        for (i + 1..antennas.len) |j| {
            try calculateAntinodesForAntennas(antennas[i], antennas[j], input, unique_antinodes);
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
    const norm_direction = normalizeVector(direction);

    var current = antenna_a;
    while (true) {
        try unique_antinodes.put(current, {});
        current = current.subSafe(norm_direction, input) catch break;
    }

    current = antenna_b;
    while (true) {
        try unique_antinodes.put(current, {});
        current = current.addSafe(norm_direction, input) catch break;
    }
}

fn normalizeVector(vector: parse.Vector2D) parse.Vector2D {
    const gcd: i32 = @intCast(std.math.gcd(@abs(vector.x), @abs(vector.y)));
    return .{
        .x = @divExact(vector.x, gcd),
        .y = @divExact(vector.y, gcd),
    };
}
