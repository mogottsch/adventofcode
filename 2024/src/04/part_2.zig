const std = @import("std");
const parse = @import("parse.zig");
const testing = std.testing;
const pretty = @import("pretty");

pub fn run(_: std.mem.Allocator, input: parse.Input) !u64 {
    var total_occurrences: u64 = 0;
    for (0..input.lines.len) |y| {
        for (0..input.lines[y].len) |x| {
            if (is_x_mas(input.lines, x, y)) {
                total_occurrences += 1;
            }
        }
    }
    return total_occurrences;
}

pub fn is_x_mas(lines: [][]const u8, x: usize, y: usize) bool {
    const width = lines[0].len;
    const height = lines.len;

    if (x < 1 or x + 1 >= width or y < 1 or y + 1 >= height) {
        return false;
    }

    return (lines[y][x] == 'A' and
        (lines[y - 1][x - 1] == 'M' or lines[y - 1][x - 1] == 'S') and
        (lines[y + 1][x - 1] == 'M' or lines[y + 1][x - 1] == 'S') and
        (lines[y - 1][x + 1] == 'M' or lines[y - 1][x + 1] == 'S') and
        (lines[y + 1][x + 1] == 'M' or lines[y + 1][x + 1] == 'S') and
        // left bottom != top right
        (lines[y - 1][x - 1] != lines[y + 1][x + 1]) and
        // right bottom != top left
        (lines[y + 1][x - 1] != lines[y - 1][x + 1]));
}
