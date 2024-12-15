const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const Bounds = struct {
    max_x: i64,
    max_y: i64,
};

pub const Robot = struct {
    x: i64,
    y: i64,
    vx: i64,
    vy: i64,

    pub fn format(
        self: Robot,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print(
            \\Position: X={}, Y={}
            \\Velocity: X={}, Y={}
            \\
        , .{ self.x, self.y, self.vx, self.vy });
    }

    pub fn move(self: *Robot, bounds: Bounds) void {
        self.x = @mod(self.x + self.vx, bounds.max_x);
        self.y = @mod(self.y + self.vy, bounds.max_y);
    }
};

pub const Input = struct {
    robots: []Robot,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        self.allocator.free(self.robots);
    }

    pub fn format(
        self: Input,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        for (self.robots) |robot| {
            try writer.print("{}---\n", .{robot});
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

    var robots = std.ArrayList(Robot).init(allocator);
    var lines = std.mem.splitScalar(u8, content, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var parts = std.mem.split(u8, line, " ");
        const pos = parts.next() orelse return error.InvalidFormat;
        const vel = parts.next() orelse return error.InvalidFormat;

        var pos_parts = std.mem.split(u8, pos[2..], ",");
        const x = try std.fmt.parseInt(i64, pos_parts.next() orelse return error.InvalidFormat, 10);
        const y = try std.fmt.parseInt(i64, pos_parts.next() orelse return error.InvalidFormat, 10);

        var vel_parts = std.mem.split(u8, vel[2..], ",");
        const vx = try std.fmt.parseInt(i64, vel_parts.next() orelse return error.InvalidFormat, 10);
        const vy = try std.fmt.parseInt(i64, vel_parts.next() orelse return error.InvalidFormat, 10);

        try robots.append(.{ .x = x, .y = y, .vx = vx, .vy = vy });
    }

    return Input{
        .robots = try robots.toOwnedSlice(),
        .allocator = allocator,
    };
}
