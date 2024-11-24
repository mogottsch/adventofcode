const std = @import("std");
const path = @import("common").path;

pub fn parse_file(allocator: std.mem.Allocator, filename: []const u8) ![]i32 {
    const filepath = try path.buildPath(filename);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    var count: usize = 0;
    for (content) |c| {
        if (c == '\n') count += 1;
    }

    const numbers = try allocator.alloc(i32, count);

    var line_iterator = std.mem.splitScalar(u8, content[0 .. content.len - 1], '\n');
    var i: usize = 0;
    while (line_iterator.next()) |line| : (i += 1) {
        numbers[i] = try std.fmt.parseInt(i32, line, 10);
    }

    return numbers;
}
