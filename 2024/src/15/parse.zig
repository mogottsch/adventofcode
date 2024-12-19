const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const CELL_WALL = '#';
pub const CELL_BOX = 'O';
pub const CELL_EMPTY = '.';
pub const CELL_GUARD = '@';

pub const Vector2D = struct {
    x: i32,
    y: i32,

    pub fn add(self: Vector2D, other: Vector2D) Vector2D {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    fn getCell(self: Vector2D, input: Input) u8 {
        return input.grid[@intCast(self.y)][@intCast(self.x)];
    }

    pub fn isWall(self: Vector2D, input: Input) bool {
        return self.getCell(input) == CELL_WALL;
    }

    pub fn isBox(self: Vector2D, input: Input) bool {
        return self.getCell(input) == CELL_BOX;
    }
};

pub const Instruction = enum(u8) {
    Up = '^',
    Down = 'v',
    Left = '<',
    Right = '>',

    pub fn toDirectionVector(self: Instruction) Vector2D {
        switch (self) {
            Instruction.Up => return .{ .x = 0, .y = -1 },
            Instruction.Down => return .{ .x = 0, .y = 1 },
            Instruction.Left => return .{ .x = -1, .y = 0 },
            Instruction.Right => return .{ .x = 1, .y = 0 },
        }
    }
};

pub const Input = struct {
    grid: [][]u8,
    instructions: []Instruction,

    allocator: std.mem.Allocator,

    pub fn deinit(self: Input) void {
        for (self.grid) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.grid);
        self.allocator.free(self.instructions);
    }

    // pub fn getCell(self: Input, position: Vector2D) u8 {
    //     return self.grid[@intCast(position.y)][@intCast(position.x)];
    // }

    pub fn print(self: Input) void {
        for (self.grid) |row| {
            std.debug.print("{s}\n", .{row});
        }
    }

    pub fn printInstructions(self: Input) void {
        std.debug.print("{any}\n", .{self.instructions});
    }

    pub fn moveBox(self: *Input, position: Vector2D, direction: Vector2D) !void {
        var new_position = position.add(direction);

        while (true) {
            const new_cell = new_position.getCell(self.*);
            if (new_cell == CELL_BOX) {
                new_position = new_position.add(direction);
                continue;
            }
            if (new_cell == CELL_WALL) {
                return error.ImmovableBox;
            }
            self.setCell(new_position, CELL_BOX);
            self.setCell(position, CELL_EMPTY);
            return;
        }
    }

    pub fn setCell(self: *Input, position: Vector2D, value: u8) void {
        self.grid[@intCast(position.y)][@intCast(position.x)] = value;
    }
};

pub fn parseFile(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    var it = std.mem.splitSequence(u8, content, "\n\n");
    const grid_block = it.next().?;

    var lines = std.ArrayList([]u8).init(allocator);
    errdefer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }
    var grid_block_it = std.mem.tokenize(u8, grid_block, "\n");
    while (grid_block_it.next()) |line| {
        const line_copy = try allocator.dupe(u8, line);
        try lines.append(line_copy);
    }

    var instructions = std.ArrayList(Instruction).init(allocator);
    errdefer instructions.deinit();
    const instructions_block = it.next().?;
    for (instructions_block) |instruction| {
        if (instruction == '\n') continue;
        try instructions.append(@enumFromInt(instruction));
    }

    const grid = try lines.toOwnedSlice();
    return Input{
        .grid = grid,
        .instructions = try instructions.toOwnedSlice(),
        .allocator = allocator,
    };
}
