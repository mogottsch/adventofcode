const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");
const string = @import("common").string;

const AllDirections = struct {
    lines: [][]const u8,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *AllDirections) void {
        for (self.lines) |line| {
            self.allocator.free(line);
        }
        self.allocator.free(self.lines);
    }
};

pub fn run(allocator: std.mem.Allocator, input: parse.Input) !u32 {
    var all_directions = try linesToAllDirections(allocator, input.lines);
    defer all_directions.deinit();

    var total_occurrences: u32 = 0;
    for (all_directions.lines) |line| {
        total_occurrences += string.countOccurrences("XMAS", line) +
            string.countOccurrences("SAMX", line);
    }

    return total_occurrences;
}

fn linesToAllDirections(allocator: std.mem.Allocator, lines: [][]const u8) !AllDirections {
    var result_list = std.ArrayList([]const u8).init(allocator);

    try readLeftToRight(allocator, lines, &result_list);
    try readTopLeftToBottomRight(allocator, lines, &result_list);
    try readTopToBottom(allocator, lines, &result_list);
    try readTopRightToBottomLeft(allocator, lines, &result_list);

    return AllDirections{
        .lines = try result_list.toOwnedSlice(),
        .allocator = allocator,
    };
}

fn readLeftToRight(
    allocator: std.mem.Allocator,
    lines: [][]const u8,
    result_list: *std.ArrayList([]const u8),
) !void {
    for (lines) |line| {
        try result_list.append(try allocator.dupe(u8, line));
    }
}
fn readTopToBottom(
    allocator: std.mem.Allocator,
    lines: [][]const u8,
    result_list: *std.ArrayList([]const u8),
) !void {
    const width = lines[0].len;
    const height = lines.len;

    for (0..width) |x| {
        var line = std.ArrayList(u8).init(allocator);
        defer line.deinit();
        for (0..height) |y| {
            try line.append(lines[y][x]);
        }
        try result_list.append(try line.toOwnedSlice());
    }
}

fn readTopLeftToBottomRight(
    allocator: std.mem.Allocator,
    lines: [][]const u8,
    result_list: *std.ArrayList([]const u8),
) !void {
    const width = lines[0].len;
    const height = lines.len;

    // Starting from bottom-left moving up
    const height_i32: i32 = @intCast(height);
    var y_start: i32 = height_i32 - 1;
    while (y_start >= 0) : (y_start -= 1) {
        try readDiagonal(allocator, lines, result_list, 0, @intCast(y_start), true);
    }

    // Starting from top moving right
    for (1..width) |x_start| {
        try readDiagonal(allocator, lines, result_list, x_start, 0, true);
    }
}

fn readTopRightToBottomLeft(
    allocator: std.mem.Allocator,
    lines: [][]const u8,
    result_list: *std.ArrayList([]const u8),
) !void {
    const width = lines[0].len;
    const height = lines.len;

    // Starting from top moving right
    for (0..width) |x_start| {
        try readDiagonal(allocator, lines, result_list, x_start, 0, false);
    }

    // Starting from second row moving down
    for (1..height) |y_start| {
        try readDiagonal(allocator, lines, result_list, width - 1, y_start, false);
    }
}

fn readDiagonal(
    allocator: std.mem.Allocator,
    lines: [][]const u8,
    result_list: *std.ArrayList([]const u8),
    x_start: usize,
    y_start: usize,
    right_direction: bool,
) !void {
    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();

    const width = lines[0].len;

    var x: i32 = @intCast(x_start);
    var y = y_start;

    while (y < lines.len and (right_direction or x >= 0) and
        (!right_direction or x < width))
    {
        try line.append(lines[y][@intCast(x)]);
        if (right_direction) {
            x += 1;
        } else {
            x -= 1;
        }
        y += 1;
    }
    try result_list.append(try line.toOwnedSlice());
}
