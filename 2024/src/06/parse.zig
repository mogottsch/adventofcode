const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const Cell = enum(u8) {
    Up = '^',
    Down = 'v',
    Left = '<',
    Right = '>',
    Obstacle = '#',
    Empty = '.',
};

pub const Vector2D = struct {
    x: i32,
    y: i32,

    pub fn add(self: Vector2D, other: Vector2D, input: Input) !Vector2D {
        // check specifically for usize overflow
        if (self.x == 0 and other.x < 0) {
            return error.OutOfBounds;
        }
        if (self.y == 0 and other.y < 0) {
            return error.OutOfBounds;
        }

        // check for general out of bounds
        if (self.x + other.x >= input.grid[0].len) {
            return error.OutOfBounds;
        }
        if (self.y + other.y >= input.grid.len) {
            return error.OutOfBounds;
        }
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }
};

pub const Input = struct {
    grid: [][]u8,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        for (self.grid) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.grid);
    }

    pub fn getCell(self: Input, position: Vector2D) !Cell {
        return try std.meta.intToEnum(Cell, self.grid[@intCast(position.y)][@intCast(position.x)]);
    }

    pub fn copy(self: Input, allocator: std.mem.Allocator) !Input {
        var new_grid = try allocator.alloc([]u8, self.grid.len);
        errdefer allocator.free(new_grid);

        for (self.grid, 0..) |row, i| {
            new_grid[i] = try allocator.dupe(u8, row);
        }

        return Input{
            .grid = new_grid,
            .allocator = allocator,
        };
    }

    pub fn copyAndPlaceObstacle(self: Input, allocator: std.mem.Allocator, position: Vector2D) !Input {
        var new_input = try self.copy(allocator);
        errdefer new_input.deinit();
        new_input.grid[@intCast(position.y)][@intCast(position.x)] = @intFromEnum(Cell.Obstacle);
        return new_input;
    }
};

pub fn parseFile(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    var lines = std.ArrayList([]u8).init(allocator);
    errdefer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    var it = std.mem.tokenize(u8, content, "\n");
    while (it.next()) |line| {
        try lines.append(try allocator.dupe(u8, line));
    }

    return Input{
        .grid = try lines.toOwnedSlice(),
        .allocator = allocator,
    };
}
