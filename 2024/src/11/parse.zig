const std = @import("std");
const path = @import("common").path;
const log = std.log;

pub const Input = struct {
    numbers: std.ArrayList(u64),

    allocator: std.mem.Allocator,

    pub fn deinit(self: *Input) void {
        self.numbers.deinit();
    }
};

pub fn parseFile(allocator: std.mem.Allocator, filename: []const u8) !Input {
    const filepath = try path.buildPath(allocator, filename);
    defer allocator.free(filepath);
    const file = try std.fs.openFileAbsolute(filepath, .{});
    defer file.close();
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    var numbers = std.ArrayList(u64).init(allocator);

    var iter = std.mem.splitScalar(u8, content[0 .. content.len - 1], ' ');
    var i: usize = 0;
    while (iter.next()) |raw_number| : (i += 1) {
        const new_number = std.fmt.parseInt(u64, raw_number, 10) catch |err| {
            log.err("Failed to parse line '{s}': {}", .{ raw_number, err });
            return err;
        };
        try numbers.append(new_number);
    }

    return Input{ .numbers = numbers, .allocator = allocator };
}
