const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const common = @import("common");
const Vector2D = parse.Vector2D;

const UpVector = Vector2D{ .x = 0, .y = -1 };
const DownVector = Vector2D{ .x = 0, .y = 1 };
const LeftVector = Vector2D{ .x = -1, .y = 0 };
const RightVector = Vector2D{ .x = 1, .y = 0 };
const Direction = enum {
    Up,
    Down,
    Left,
    Right,

    pub fn getVector(self: Direction) Vector2D {
        switch (self) {
            Direction.Up => return UpVector,
            Direction.Down => return DownVector,
            Direction.Left => return LeftVector,
            Direction.Right => return RightVector,
        }
    }
};
pub const ALL_DIRECTIONS = [_]Direction{ Direction.Up, Direction.Down, Direction.Left, Direction.Right };

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var sum_trail_heads: u64 = 0;
    var cache = std.AutoHashMap(Vector2D, u64).init(allocator);
    try cache.ensureTotalCapacity(@intCast(input.grid.len * input.grid[0].len));
    defer cache.deinit();

    for (0..input.grid.len) |y| {
        for (0..input.grid[0].len) |x| {
            const position = Vector2D.initFromUsize(x, y);
            if (input.getCell(position) == 0) {
                sum_trail_heads += try countTrailHead(
                    allocator,
                    input,
                    position,
                    &cache,
                );
            }
        }
    }
    return sum_trail_heads;
}

fn countTrailHead(
    allocator: std.mem.Allocator,
    input: parse.Input,
    trail_head: parse.Vector2D,
    cache: *std.AutoHashMap(Vector2D, u64),
) !u64 {
    if (cache.get(trail_head)) |count| {
        return count;
    }

    const bit_set_size: usize = @intCast(input.grid.len * input.grid[0].len);
    var reached_trail_ends = try std.bit_set.DynamicBitSet.initEmpty(allocator, bit_set_size);
    defer reached_trail_ends.deinit();
    traverseTrailHead(input, trail_head, &reached_trail_ends);
    const count = @as(u64, @intCast(reached_trail_ends.count()));
    try cache.put(trail_head, count);
    return count;
}

fn traverseTrailHead(
    input: parse.Input,
    trailHead: parse.Vector2D,
    reached_trail_ends: *std.bit_set.DynamicBitSet,
) void {
    const position = trailHead;
    const current_cell = input.getCell(position);

    for (ALL_DIRECTIONS) |direction| {
        const new_position = position.addSafe(direction.getVector(), input) catch continue;
        const new_cell = input.getCell(new_position);
        if (current_cell + 1 != new_cell) continue;

        const idx = new_position.toIdx(input);
        if (new_cell == 9) {
            reached_trail_ends.set(idx);
            continue;
        }
        traverseTrailHead(input, new_position, reached_trail_ends);
    }
}
