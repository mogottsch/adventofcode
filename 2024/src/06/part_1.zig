const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const Vector2D = parse.Vector2D;
const Cell = parse.Cell;

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

    pub fn turn90DegreesRight(self: Direction) Direction {
        switch (self) {
            Direction.Up => return Direction.Right,
            Direction.Down => return Direction.Left,
            Direction.Left => return Direction.Up,
            Direction.Right => return Direction.Down,
        }
    }
};

const Guard = struct {
    position: Vector2D,
    direction: Direction,

    fn getView(self: Guard, input: parse.Input) !Cell {
        const view = try self.position.add(self.direction.getVector(), input);
        return try input.getCell(view);
    }

    fn turn90DegreesRight(self: Guard) Guard {
        return Guard{
            .position = self.position,
            .direction = self.direction.turn90DegreesRight(),
        };
    }

    fn moveForward(self: Guard, input: parse.Input) !Guard {
        const new_position = try self.position.add(self.direction.getVector(), input);
        return Guard{
            .position = new_position,
            .direction = self.direction,
        };
    }

    fn facesObstacle(guard: Guard, input: parse.Input) bool {
        const view = guard.getView(input) catch return false;
        return view == Cell.Obstacle;
    }
};

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u32 {
    // try pretty.print(allocator, input, .{});
    var guard = try findGuard(input);
    // try pretty.print(allocator, guard, .{});

    var visited = std.AutoHashMap(Vector2D, void).init(allocator);
    defer visited.deinit();

    while (true) {
        try visited.put(guard.position, {});
        guard = doStep(guard, input) catch |err| {
            if (err == error.OutOfBounds) {
                break;
            }
            return err;
        };
        // try pretty.print(allocator, guard, .{});
    }

    return visited.count();
}

fn findGuard(input: parse.Input) !Guard {
    const grid = input.grid;
    for (grid, 0..) |row, row_index| {
        for (row, 0..) |raw_cell, col_index| {
            const position = Vector2D{ .x = @intCast(col_index), .y = @intCast(row_index) };
            const cell = try std.meta.intToEnum(Cell, raw_cell);
            switch (cell) {
                Cell.Up => return Guard{
                    .position = position,
                    .direction = Direction.Up,
                },
                Cell.Down => return Guard{
                    .position = position,
                    .direction = Direction.Down,
                },
                Cell.Left => return Guard{
                    .position = position,
                    .direction = Direction.Left,
                },
                Cell.Right => return Guard{
                    .position = position,
                    .direction = Direction.Right,
                },
                else => {},
            }
        }
    }
    unreachable;
}

fn doStep(guard: Guard, input: parse.Input) !Guard {
    var new_guard = guard;
    if (guard.facesObstacle(input)) {
        new_guard = new_guard.turn90DegreesRight();
    }
    return try new_guard.moveForward(input);
}
