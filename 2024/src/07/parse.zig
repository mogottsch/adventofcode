const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const Equation = struct {
    left: u64,
    right: []u64,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Equation) void {
        self.allocator.free(self.right);
    }
};

pub const Input = struct {
    equations: []Equation,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        for (self.equations) |*equation| {
            equation.deinit();
        }
        self.allocator.free(self.equations);
    }
};

pub fn parse_file(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);
    var equations = std.ArrayList(Equation).init(allocator);

    var line_iterator = std.mem.splitScalar(u8, content[0 .. content.len - 1], '\n');

    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const equation = try parseLine(allocator, line);
        try equations.append(equation);
    }

    return Input{
        .equations = try equations.toOwnedSlice(),
        .allocator = allocator,
    };
}

pub fn parseLine(allocator: std.mem.Allocator, line: []const u8) !Equation {
    var parts = std.mem.splitSequence(u8, line, ": ");
    const raw_left = parts.next().?;
    const left = std.fmt.parseInt(u64, raw_left, 10) catch |err| {
        log.err("Failed to parse left side of equation: {s}", .{raw_left});
        return err;
    };
    const right = try parseNumbers(allocator, parts.next().?);
    return Equation{ .left = left, .right = right, .allocator = allocator };
}

pub fn parseNumbers(allocator: std.mem.Allocator, numbers: []const u8) ![]u64 {
    var parts = std.mem.splitScalar(u8, numbers, ' ');
    var result = std.ArrayList(u64).init(allocator);
    defer result.deinit();
    while (parts.next()) |part| {
        const number = std.fmt.parseInt(u64, part, 10) catch |err| {
            log.err("Failed to parse: {s}", .{part});
            return err;
        };
        try result.append(number);
    }
    return result.toOwnedSlice();
}
