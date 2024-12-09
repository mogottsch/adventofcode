const std = @import("std");
const path = @import("common").path;
const log = std.log;

const EMPTY_CELL = '.';

pub const Vector2D = struct {
    x: i32,
    y: i32,

    pub fn addSafe(self: Vector2D, other: Vector2D, input: Input) !Vector2D {
        const new = self.add(other);
        if (new.isOutOfBounds(input)) return error.OutOfBounds;
        return new;
    }

    pub fn add(self: Vector2D, other: Vector2D) Vector2D {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn sub(self: Vector2D, other: Vector2D) Vector2D {
        return .{ .x = self.x - other.x, .y = self.y - other.y };
    }

    pub fn subSafe(self: Vector2D, other: Vector2D, input: Input) !Vector2D {
        const new = self.sub(other);
        if (new.isOutOfBounds(input)) return error.OutOfBounds;
        return new;
    }

    pub fn isOutOfBounds(self: Vector2D, input: Input) bool {
        return self.x < 0 or self.y < 0 or self.x >= input.grid[0].len or self.y >= input.grid.len;
    }
};

pub const Input = struct {
    grid: [][]u8,
    antennas: std.AutoHashMap(u8, std.ArrayList(Vector2D)),

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        for (self.grid) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.grid);

        var it = self.antennas.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        self.antennas.deinit();
    }

    pub fn print(self: Input) void {
        for (self.grid) |row| {
            std.debug.print("{s}\n", .{row});
        }
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

    const grid = try lines.toOwnedSlice();
    return Input{
        .grid = grid,
        .antennas = try getAntennasByFrequency(allocator, grid),
        .allocator = allocator,
    };
}

fn getAntennasByFrequency(allocator: std.mem.Allocator, grid: [][]u8) !std.AutoHashMap(u8, std.ArrayList(Vector2D)) {
    var result = std.AutoHashMap(u8, std.ArrayList(Vector2D)).init(allocator);
    errdefer result.deinit();

    for (grid, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == EMPTY_CELL) {
                continue;
            }
            const position = Vector2D{ .x = @intCast(x), .y = @intCast(y) };
            const gop = try result.getOrPut(cell);
            if (!gop.found_existing) {
                gop.value_ptr.* = std.ArrayList(Vector2D).init(allocator);
            }
            try gop.value_ptr.append(position);
        }
    }

    return result;
}
