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

    fn add(self: Vector2D, other: Vector2D) Vector2D {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn initFromUsize(x: usize, y: usize) Vector2D {
        return .{ .x = @intCast(x), .y = @intCast(y) };
    }

    pub fn isOutOfBounds(self: Vector2D, input: Input) bool {
        return self.x < 0 or self.y < 0 or self.x >= input.grid[0].len or self.y >= input.grid.len;
    }

    pub fn toIdx(self: Vector2D, input: Input) usize {
        return @as(usize, @intCast(self.y * @as(i32, @intCast(input.grid[0].len)) + self.x));
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

    pub fn getCell(self: Input, position: Vector2D) u8 {
        return self.grid[@intCast(position.y)][@intCast(position.x)];
    }

    pub fn print(self: Input) void {
        for (self.grid) |row| {
            std.debug.print("{d}\n", .{row});
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
        var row = try allocator.alloc(u8, line.len);
        for (0..line.len) |i| {
            if (line[i] == '.') {
                row[i] = 200;
                continue;
            }
            row[i] = line[i] - '0'; // fast char to int conversion
        }
        try lines.append(row);
    }

    const grid = try lines.toOwnedSlice();
    return Input{
        .grid = grid,
        .allocator = allocator,
    };
}
