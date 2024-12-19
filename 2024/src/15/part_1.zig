const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

const Vector2D = parse.Vector2D;
const Instruction = parse.Instruction;

pub const Guard = struct {
    position: Vector2D,

    fn performInstruction(
        self: Guard,
        input: *parse.Input,
        instruction: parse.Instruction,
    ) Guard {
        const direction_vector = instruction.toDirectionVector();
        const new_position = self.position.add(direction_vector);

        if (new_position.isWall(input.*)) {
            return self;
        }
        if (new_position.isBox(input.*)) {
            input.moveBox(new_position, direction_vector) catch return self;
        }

        input.setCell(self.position, parse.CELL_EMPTY);
        input.setCell(new_position, parse.CELL_GUARD);
        return Guard{ .position = new_position };
    }
};

pub fn run(allocator: std.mem.Allocator, initial_state: parse.Input) !u64 {
    _ = allocator;
    var game_state = initial_state;

    var guard = try findGuard(&game_state);
    for (game_state.instructions) |instruction| {
        guard = guard.performInstruction(&game_state, instruction);
    }

    return sumBoxCoordinates(game_state);
}

pub fn findGuard(input: *parse.Input) !Guard {
    for (input.grid, 0..) |row, row_index| {
        for (row, 0..) |raw_cell, col_index| {
            if (raw_cell == parse.CELL_GUARD) {
                return Guard{
                    .position = .{
                        .x = @intCast(col_index),
                        .y = @intCast(row_index),
                    },
                };
            }
        }
    }
    return error.GuardNotFound;
}

// 100 * y + x
fn sumBoxCoordinates(input: parse.Input) u64 {
    var sum: u64 = 0;
    for (input.grid, 0..) |row, row_index| {
        for (row, 0..) |cell, col_index| {
            if (cell == parse.CELL_BOX) {
                sum += 100 * row_index + col_index;
            }
        }
    }
    return sum;
}
