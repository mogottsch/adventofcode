const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const Vector2D = parse.Vector2D;
const part_1 = @import("part_1.zig");
const ALL_DIRECTIONS = part_1.ALL_DIRECTIONS;

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var sum_trail_heads: u64 = 0;
    for (0..input.grid.len) |y| {
        for (0..input.grid[0].len) |x| {
            const position = Vector2D.initFromUsize(x, y);
            if (input.getCell(position) == 0) {
                const to_add = try countTrailHead(allocator, input, position);
                sum_trail_heads += to_add;
            }
        }
    }
    return sum_trail_heads;
}

fn countTrailHead(allocator: std.mem.Allocator, input: parse.Input, trail_head: parse.Vector2D) !u64 {
    return try traverseTrailHead(allocator, input, trail_head);
}

fn traverseTrailHead(
    allocator: std.mem.Allocator,
    input: parse.Input,
    trailHead: parse.Vector2D,
) !u64 {
    var position = trailHead;
    const current_cell = input.getCell(position);
    if (current_cell == 9) return 1;

    var n_reached_trail_ends: u64 = 0;

    for (ALL_DIRECTIONS) |direction| {
        const new_position = position.addSafe(direction.getVector(), input) catch continue;
        const new_cell = input.getCell(new_position);
        if (current_cell + 1 != new_cell) continue;

        n_reached_trail_ends += try traverseTrailHead(allocator, input, new_position);
    }
    return n_reached_trail_ends;
}
