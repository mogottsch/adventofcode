const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const part_1 = @import("part_1.zig");
const Vector2D = parse.Vector2D;

// maybe some cache would help to speed this up
pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var guard = try part_1.findGuard(input);
    const starting_position = guard.position;

    var checked_positions = std.AutoHashMap(part_1.Guard, void).init(allocator);
    defer checked_positions.deinit();

    var placed_obstacles = std.AutoHashMap(Vector2D, void).init(allocator);
    defer placed_obstacles.deinit();

    var possible_positions: u64 = 0;

    while (true) {
        if (checked_positions.contains(guard)) {
            break;
        }

        try checked_positions.put(guard, {});

        const pos_in_front = guard.getViewVector(input) catch |err| {
            if (err == error.OutOfBounds) {
                break;
            }
            return err;
        };

        if (
        // can't place Obstacle at guards starting position
        (pos_in_front.x == starting_position.x and pos_in_front.y == starting_position.y) or
            // can't place Obstacle where already obstacle
            (try input.getCell(pos_in_front) == parse.Cell.Obstacle) or
            // can't place Obstacle where already obstacle was placed
            placed_obstacles.contains(pos_in_front))
        {
            guard = try guard.doStep(input);
            continue;
        }

        var input_to_check = try input.copyAndPlaceObstacle(allocator, pos_in_front);
        defer input_to_check.deinit();
        if (try checkCircle(allocator, input_to_check, guard)) {
            try placed_obstacles.put(pos_in_front, {});
            possible_positions += 1;
        }

        guard = try guard.doStep(input);
    }
    return possible_positions;
}

pub fn run2(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    const guard = try part_1.findGuard(input);
    const starting_position = guard.position;

    var possible_positions: u64 = 0;

    var progress: u64 = 0;
    const grid_len: f32 = @floatFromInt(input.grid.len);
    const grid_inner_len: f32 = @floatFromInt(input.grid[0].len);
    const total: f32 = grid_len * grid_inner_len;

    for (input.grid, 0..) |_, y| {
        for (input.grid, 0..) |_, x| {
            progress += 1;
            const progress_f: f32 = @floatFromInt(progress);
            const progress_perc: f32 = progress_f / total;
            std.debug.print("{d}/{d}\n", .{ progress_perc, 100 });
            if (x == starting_position.x and y == starting_position.y) {
                continue;
            }

            var input_to_check = try input.copyAndPlaceObstacle(
                allocator,
                Vector2D{ .x = @intCast(x), .y = @intCast(y) },
            );
            defer input_to_check.deinit();

            if (try checkCircle(allocator, input_to_check, guard)) {
                possible_positions += 1;
            }
        }
    }

    return possible_positions;
}

pub fn checkCircle(allocator: std.mem.Allocator, input: parse.Input, guard: part_1.Guard) !bool {
    var visited = std.AutoHashMap(part_1.Guard, void).init(allocator);
    defer visited.deinit();

    var current_guard = guard;

    while (true) {
        if (visited.contains(current_guard)) {
            return true;
        }
        try visited.put(current_guard, {});

        current_guard = current_guard.doStep(input) catch |err| {
            if (err == error.OutOfBounds) {
                return false;
            }
            return err;
        };
    }
}

pub fn printInputWithGuard(input: parse.Input, guard: part_1.Guard) void {
    _ = guard;
    std.debug.print("---------------------------------\n", .{});
    for (input.grid) |row| {
        std.debug.print("{s}\n", .{row});
    }
    std.debug.print("---------------------------------\n", .{});
}
