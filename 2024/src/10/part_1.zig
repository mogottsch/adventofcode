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
    // input.print();

    var sum_trail_heads: u64 = 0;
    for (0..input.grid.len) |y| {
        for (0..input.grid[0].len) |x| {
            const position = Vector2D.initFromUsize(x, y);
            if (input.getCell(position) == 0) {
                sum_trail_heads += try countTrailHead(allocator, input, position);
            }
        }
    }
    return sum_trail_heads;
}

fn countTrailHead(allocator: std.mem.Allocator, input: parse.Input, trail_head: parse.Vector2D) !u64 {
    var reached_trail_ends = std.AutoHashMap(Vector2D, void).init(allocator);
    defer reached_trail_ends.deinit();
    try traverseTrailHead(allocator, input, trail_head, &reached_trail_ends);
    return reached_trail_ends.count();
}

fn traverseTrailHead(
    allocator: std.mem.Allocator,
    input: parse.Input,
    trailHead: parse.Vector2D,
    reached_trail_ends: *std.AutoHashMap(parse.Vector2D, void),
) !void {
    var position = trailHead;
    const current_cell = input.getCell(position);

    for (ALL_DIRECTIONS) |direction| {
        const new_position = position.addSafe(direction.getVector(), input) catch continue;
        const new_cell = input.getCell(new_position);
        if (current_cell + 1 != new_cell) continue;

        if (new_cell == 9) {
            try reached_trail_ends.put(new_position, {});
            continue;
        }
        try traverseTrailHead(allocator, input, new_position, reached_trail_ends);
    }
}
