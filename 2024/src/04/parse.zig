const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const Input = struct {
    lines: [][]const u8,
    original_content: []const u8,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        self.allocator.free(self.lines);
        self.allocator.free(self.original_content);
    }
};

pub fn parseFile(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    errdefer allocator.free(content);

    var line_iterator = std.mem.splitScalar(u8, content, '\n');
    var lines = std.ArrayList([]const u8).init(allocator);
    errdefer lines.deinit();

    while (line_iterator.next()) |line| {
        try lines.append(line);
    }

    _ = lines.pop();

    return Input{
        .lines = try lines.toOwnedSlice(),
        .original_content = content,
        .allocator = allocator,
    };
}
