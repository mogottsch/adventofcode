const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const part_1 = @import("part_1.zig");

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u64 {
    var expanded_input = try expandInputGrid(allocator, input);
    defer expanded_input.deinit();

    var game_state = expanded_input;

    var guard = try part_1.findGuard(&game_state);
    for (game_state.instructions) |instruction| {
        guard = performInstruction(allocator, guard, &game_state, instruction);
    }

    return sumBoxCoordinates(game_state);
}

fn performInstruction(
    allocator: std.mem.Allocator,
    guard: part_1.Guard,
    input: *parse.Input,
    instruction: parse.Instruction,
) part_1.Guard {
    const direction_vector = instruction.toDirectionVector();
    const new_position = guard.position.add(direction_vector);

    if (new_position.isWall(input.*)) {
        return guard;
    }
    if (new_position.isLargeBox(input.*)) {
        input.moveLargeBox(allocator, new_position, direction_vector) catch return guard;
    }

    input.setCell(guard.position, parse.CELL_EMPTY);
    input.setCell(new_position, parse.CELL_GUARD);
    return part_1.Guard{ .position = new_position };
}

// . becomes ..
// # becomes ##
// @ becomes @.
// O becomes []
fn expandInputGrid(allocator: std.mem.Allocator, input: parse.Input) !parse.Input {
    var new_grid = try std.ArrayList([]u8).initCapacity(allocator, input.grid.len);
    errdefer {
        for (new_grid.items) |row| {
            allocator.free(row);
        }
        new_grid.deinit();
    }

    for (input.grid) |row| {
        var new_row = try allocator.alloc(u8, row.len * 2);
        errdefer allocator.free(new_row);

        var i: usize = 0;
        for (row) |cell| {
            switch (cell) {
                parse.CELL_WALL => {
                    new_row[i] = parse.CELL_WALL;
                    new_row[i + 1] = parse.CELL_WALL;
                },
                parse.CELL_BOX => {
                    new_row[i] = parse.CELL_BOX_LEFT;
                    new_row[i + 1] = parse.CELL_BOX_RIGHT;
                },
                parse.CELL_EMPTY => {
                    new_row[i] = parse.CELL_EMPTY;
                    new_row[i + 1] = parse.CELL_EMPTY;
                },
                parse.CELL_GUARD => {
                    new_row[i] = parse.CELL_GUARD;
                    new_row[i + 1] = parse.CELL_EMPTY;
                },
                else => unreachable,
            }
            i += 2;
        }

        try new_grid.append(new_row);
    }

    return parse.Input{
        .grid = try new_grid.toOwnedSlice(),
        .instructions = try allocator.dupe(parse.Instruction, input.instructions),
        .allocator = allocator,
    };
}

pub fn sumBoxCoordinates(input: parse.Input) u64 {
    var sum: u64 = 0;
    for (input.grid, 0..) |row, row_index| {
        for (row, 0..) |cell, col_index| {
            if (cell == parse.CELL_BOX_LEFT) {
                sum += 100 * row_index + col_index;
            }
        }
    }
    return sum;
}
