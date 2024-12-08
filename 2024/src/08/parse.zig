const std = @import("std");
const path = @import("common").path;
const log = std.log;

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

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        for (self.grid) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.grid);
    }

    pub fn print(self: Input) void {
        for (self.grid) |row| {
            std.debug.print("{s}\n", .{row});
        }
    }
};

pub fn parse_file(allocator: std.mem.Allocator, filename: []const u8) !Input {
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
