const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const Input = struct {
    left: []u64,
    right: []u64,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        self.allocator.free(self.left);
        self.allocator.free(self.right);
    }
};

pub fn parseFile(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    var count: usize = 0;
    for (content) |c| {
        if (c == '\n') count += 1;
    }

    const left = try allocator.alloc(u64, count);
    errdefer allocator.free(left);

    const right = try allocator.alloc(u64, count);
    errdefer allocator.free(right);

    var line_iterator = std.mem.splitScalar(u8, content[0 .. content.len - 1], '\n');
    var i: usize = 0;
    while (line_iterator.next()) |line| : (i += 1) {
        var parts = std.mem.splitSequence(u8, line, "   ");
        const left_part = parts.next().?;
        const right_part = parts.next().?;

        left[i] = try std.fmt.parseInt(u64, left_part, 10);
        right[i] = try std.fmt.parseInt(u64, right_part, 10);
    }

    return Input{ .left = left, .right = right, .allocator = allocator };
}
