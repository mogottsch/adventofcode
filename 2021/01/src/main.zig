const std = @import("std");
const testing = std.testing;
const info = std.log.info;

pub fn readFileLines(allocator: std.mem.Allocator, filepath: []const u8) ![]const []const u8 {
    const file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    var count: usize = 0;
    for (content) |c| {
        if (c == '\n') count += 1;
    }

    const lines = try allocator.alloc([]const u8, count);

    var line_iterator = std.mem.splitScalar(u8, content[0 .. content.len - 1], '\n');
    var i: usize = 0;
    while (line_iterator.next()) |line| : (i += 1) {
        lines[i] = line;
    }

    return lines;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const lines = try readFileLines(allocator, "input.txt");
    defer allocator.free(lines);

    const n_increases = try part_1(lines);

    info("{d}", .{n_increases});
}

pub fn part_1(lines: []const []const u8) !i32 {
    var last_number: ?i32 = null;
    var n_increases: i32 = 0;
    for (lines) |line| {
        const number = try std.fmt.parseInt(i32, line, 10);
        if (last_number != null and number > last_number.?) {
            n_increases += 1;
        }
        last_number = number;
    }
    return n_increases;
}

const EXAMPLE_ANSWER_A: i32 = 7;

test "part 1" {
    const allocator = std.heap.page_allocator;
    const lines = try readFileLines(allocator, "example_1.txt");
    defer allocator.free(lines);

    const result = part_1(lines);
    try testing.expectEqual(result, EXAMPLE_ANSWER_A);
}
