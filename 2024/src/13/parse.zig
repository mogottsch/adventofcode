const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const System = struct {
    a_x: u64,
    a_y: u64,

    b_x: u64,
    b_y: u64,

    p_x: u64,
    p_y: u64,

    pub fn format(
        self: System,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print(
            \\Button A: X+{}, Y+{}
            \\Button B: X+{}, Y+{}
            \\Prize: X={}, Y={}
            \\
        , .{ self.a_x, self.a_y, self.b_x, self.b_y, self.p_x, self.p_y });
    }
};

pub const Input = struct {
    allocator: std.mem.Allocator,
    systems: []System,

    pub fn deinit(self: *Input) void {
        self.allocator.free(self.systems);
    }

    pub fn format(
        self: Input,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        for (self.systems) |system| {
            try writer.print("{}---\n", .{system});
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

    var systems = std.ArrayList(System).init(allocator);
    defer systems.deinit();

    var lines = std.mem.split(u8, content, "\n");
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        if (std.mem.startsWith(u8, line, "Button A:")) {
            var system: System = undefined;

            var a_parts = std.mem.split(u8, line[9..], ",");
            system.a_x = try std.fmt.parseInt(u64, a_parts.next().?[2..], 10);
            system.a_y = try std.fmt.parseInt(u64, a_parts.next().?[3..], 10);

            const b_line = lines.next().?;
            var b_parts = std.mem.split(u8, b_line[9..], ",");
            system.b_x = try std.fmt.parseInt(u64, b_parts.next().?[2..], 10);
            system.b_y = try std.fmt.parseInt(u64, b_parts.next().?[3..], 10);

            const p_line = lines.next().?;
            var p_parts = std.mem.split(u8, p_line[7..], ",");
            system.p_x = try std.fmt.parseInt(u64, p_parts.next().?[2..], 10);
            system.p_y = try std.fmt.parseInt(u64, p_parts.next().?[3..], 10);

            try systems.append(system);
        }
    }

    return Input{
        .allocator = allocator,
        .systems = try systems.toOwnedSlice(),
    };
}
