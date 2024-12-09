const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const EMTPY_CHAR: u64 = std.math.maxInt(u64);
// pub const EMTPY_CHAR: u64 = 100;

pub const Input = struct {
    disk: []u64,

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        self.allocator.free(self.disk);
    }
};

pub fn parseFile(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    var disk_list = std.ArrayList(u64).init(allocator);
    var file_id: u64 = 0;
    var is_file = true;

    for (content) |char| {
        if (char == '\n') break;

        var char_to_append: u64 = EMTPY_CHAR;

        if (is_file) {
            char_to_append = file_id;
            file_id += 1;
            std.debug.assert(file_id != EMTPY_CHAR);
        }

        is_file = !is_file;

        std.debug.assert(char >= '0' and char <= '9');
        const size = char - '0';
        for (0..size) |_| {
            try disk_list.append(char_to_append);
        }
    }

    return Input{ .disk = try disk_list.toOwnedSlice(), .allocator = allocator };
}
